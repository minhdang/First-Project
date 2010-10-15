class Payment < ActiveRecord::Base
  include AASM # Rubyist's Acts as State Machine
  
  class FailedTransactionError < StandardError; end;
  
  # Valid Payment types
  IDEA_PAYMENT_TYPE            = "Idea Entry"
  OPT_IN_PAYMENT_TYPE          = "Opt In"
  SURVEY_RESPONSE_PAYMENT_TYPE = "Survey Response"
  SUBSCRIPTION_PAYMENT_TYPE    = "Subscription"
  SUBSCRIPTION_REDEMPTION_TYPE = "Redeem Subscription"
  SPECIAL_OFFER                = "Special Offer"
  ORDER_PAYMENT_TYPE           = "Order"
  
  belongs_to :chargeable, :polymorphic => true
  
  has_one :billing_address, :as => 'contactable', :class_name => 'ContactInformation'
  accepts_nested_attributes_for :billing_address
  
  validates_presence_of :amount, :billing_address
  validates_associated :billing_address
  validates_numericality_of :amount, :allow_blank => true
  validate :valid_credit_card, :if => :card_required?
  
  before_validation_on_create :decide_payment_type, :unless => :payment_type
  
  # Virtual attributes for sensitive information that
  # will not be saved to the database
  attr_accessor :card_number, :security_code, :skip_card_validation
  
  # Keep users from changing important info
  attr_protected :amount, :cc_number, :chargeable, :chargeable_id, :chargeable_type, :payment_type
  
  aasm_column :status
  aasm_initial_state :pending
  
  aasm_state :pending
  aasm_state :approved
  aasm_state :declined
  aasm_state :error
  aasm_state :fraud_review
  
  aasm_event :approve do
    transitions :to => :approved, :from => [:pending, :declined, :error, :fraud_review]
  end
  
  aasm_event :decline do
    transitions :to => :declined, :from => [:pending, :error, :fraud_review, :approved]
  end
  
  aasm_event :error do
    transitions :to => :error, :from => [:pending, :declined, :fraud_review, :approved]
  end
  
  aasm_event :fraud_review do
    transitions :to => :fraud_review, :from => [:pending, :declined, :error, :approved]
  end
  
  # Attempt to process this payment
  def process!
    log_payment("Attempting to process payment: #{self}")
    if valid?
      response = process_payment
      log_payment "Processing - Received response: Success=#{response.success?} Auth=#{response.authorization} Params=<#{response.params}> Mesage=#{response.message}"
      
      # Save the response reason code
      # Helps describe the specific problem
      self.response_reason_code = response.params['response_reason_code'] || response.params['result_code']
      
      self.authorization_code = response.authorization if response.success?
      self.cc_number = credit_card.display_number
      
      # Move to the state that correlates to the response code
      code = response.params['response_code'] || response.params['result_code']
      move_to_state!(code)

      unless approved?
        log_payment("Processing Failed - Not Approved: #{response.message}")
        errors.add_to_base("The transaction was unsuccessful because #{response.message}")
      end
      
      log_payment("Finished Processing: #{self}")
    else
      errors.add_to_base("The credit card information is not valid.")
      log_payment("Processing Failed - Invalid Payment: #{self.errors.full_messages.to_sentence}")
    end

    return approved?
  end
  
  # ActiveMerchant takes currency in cents instead of dollars
  def amount_in_cents
    (amount * 100).to_i
  end
  
  # Update a recurring subscription with this payments information
  def update_subscription(sub_id)
    log_payment("Attempting to Update ARB: #{self}")
    
    response = nil
    if valid?
      response = Payment.gateway.update_recurring({
                    :subscription_id  => sub_id,
                    :credit_card      => credit_card,
                    :billing_address  => billing_address.attributes_for_active_merchant
                  })
                  
      update_attribute(:cc_number, credit_card.display_number) if response.success?
      
      unless response.success?
        errors.add_to_base("The transaction was unsuccessful because #{response.message}") 
        log_payment("Update ARB Failed: #{response.message}")
      end
      
      log_payment("Finished Updating ARB: #{self}")
    end

    response && response.success?
  end
  
  # Cancel the recurring billing subscription at Auth.net
  def self.cancel_subscription(subscription_id)
    Payment.gateway.cancel_recurring(subscription_id)
  end
  
  # String Representation of Payment
  def to_s
    "Payment Attribs: <#{attributes.sort.to_a.map{|attrib| "#{attrib[0].upcase} = #{attrib[1]}"}.to_sentence}> Payment Errors: <#{self.errors.full_messages.to_sentence}>"
  end
  
  protected
    # process the payment through the gateway
    # decide whether its a purchase or setting up a recurring billing subscription
    def process_payment
      response =  case payment_type
                  when SUBSCRIPTION_PAYMENT_TYPE
                    Payment.gateway.recurring(amount_in_cents, credit_card, payment_options)
                  else
                    Payment.gateway.purchase(amount_in_cents, credit_card, payment_options)
                  end
    end
    
    # The Credit Card object that Active Merchant will use
    # when talking to the payment gateway
    def credit_card
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new({
        :first_name         => billing_address.first_name,
        :last_name          => billing_address.last_name,
        :type               => cc_type,
        :number             => card_number,
        :verification_value => security_code,
        :month              => cc_exp_month,
        :year               => cc_exp_year
      })
    end
    
    def card_required?
      return false if skip_card_validation
      new_record? || card_number
    end
    
    # Validate the credit card object and copy over its errors
    # to our matching attributes if it has any
    def valid_credit_card
      unless billing_address && credit_card.valid?
        errors.add(:cc_type, credit_card.errors.on(:type)) if credit_card.errors.on(:type)
        errors.add(:card_number, credit_card.errors.on(:number)) if credit_card.errors.on(:number)
        errors.add(:cc_exp_month, "month #{credit_card.errors.on(:month)}") if credit_card.errors.on(:month)
        errors.add(:cc_exp_year, "year #{credit_card.errors.on(:year)}") if credit_card.errors.on(:year)
        errors.add(:security_code, credit_card.errors.on(:verification_value)) if credit_card.errors.on(:verification_value)
      end
    end
    
    def default_payment_options
      {
        :customer         => chargeable.user_id,
        :billing_address  => billing_address.attributes_for_active_merchant,
        :description      => "Transaction: #{chargeable.class.name} ID: #{chargeable.id} -- User: #{chargeable.user_id}",
        :order_id         => chargeable.id
      }
    end
    
    # Payment options to be sent to Authorize.net
    # depending on the current payment type
    def payment_options
      type_options =  case payment_type
                      when IDEA_PAYMENT_TYPE
                        {
                          :description        =>
                            "LPS Submission: Submission##{chargeable.key} #{chargeable.live_product_search.sponsor.name}"
                        }
                      when OPT_IN_PAYMENT_TYPE
                        {
                          :description        =>
                            "LPS Submission: Submission##{chargeable.key} #{chargeable.live_product_search.sponsor.name}"
                        }
                      when SURVEY_RESPONSE_PAYMENT_TYPE
                        {
                          :description        =>
                            "Survey Response: Response##{chargeable.id}"
                        }
                      when SUBSCRIPTION_PAYMENT_TYPE
                        {
                          :subscription_name  => "User #{chargeable.user_id} upgraded to gold",
                          :customer           => {:id => chargeable.user_id },
                          :interval           => {:length => 1, :unit => :months},
                          :duration           => {:start_date => Time.now.utc.to_date, :occurrences => 1000}
                        }
                      when SUBSCRIPTION_REDEMPTION_TYPE
                        {
                          :description        => "User #{chargeable.user_id} recovered his/her Edison Insider Membership"
                        }
                      when SPECIAL_OFFER
                        {
                          :description        => "Special Offer - Transaction: #{chargeable.class.name} ID: #{chargeable.id} -- User: #{chargeable.user_id}"
                        }
                      when ORDER_PAYMENT_TYPE
                        {
                          :description        => "#{h(chargeable.store.name)} Order ##{chargeable.number}"
                        }
                      end

      default_payment_options.merge(type_options)
    end
    
    # Move to a state that correlates with a
    # response code from Auth.net
    def move_to_state!(code)
      code = code.to_i if code =~ /^[1-4]$/ # If this is a code between 1-4 go ahead and make it an integer
      log_payment("Moving to state for code #{code}: #{self}")
      case code
      when ActiveMerchant::Billing::AuthorizeNetGateway::APPROVED
        approve! unless approved?
      when 'Ok' # Recurring billing has been approved
        approve! unless approved?
      when ActiveMerchant::Billing::AuthorizeNetGateway::DECLINED
        decline! unless declined?
      when ActiveMerchant::Billing::AuthorizeNetGateway::ERROR
        error! unless error?
      when ActiveMerchant::Billing::AuthorizeNetGateway::FRAUD_REVIEW
        fraud_review! unless error?
      else # Unknow code - let's error out the payment
        error! unless error?
      end
    end
    
    # The gateway we will use to process our payment
    def self.gateway
      ActiveMerchant::Billing::Base.gateway_mode = :test if App.active_merchant[:test_mode] # Needed to work around bug in ActiveMerchant's Auth.net Gateway
      @gateway ||= ActiveMerchant::Billing::AuthorizeNetGateway.new(:login =>    App.active_merchant[:login],
                                                                    :password => App.active_merchant[:password],
                                                                    :test =>     App.active_merchant[:test_mode])
    end
    
    def decide_payment_type
      self.payment_type = case chargeable_type
                          when 'Membership'
                            SUBSCRIPTION_PAYMENT_TYPE
                          when 'Order'
                            ORDER_PAYMENT_TYPE
                          when 'Submission'
                            chargeable.will_be_first? ? IDEA_PAYMENT_TYPE : OPT_IN_PAYMENT_TYPE
                          when 'SurveyResponse'
                            SURVEY_RESPONSE_PAYMENT_TYPE
                          end
    end
    
    def log_payment(msg)
      Rails.logger.info "PAYMENT: #{msg}"
    end
end
