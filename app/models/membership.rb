class Membership < ActiveRecord::Base
  class ActivationUnsuccessfulError < StandardError
  end
  
  include AASM # Rubyist's Acts As State Machine
  
  belongs_to :user
  has_one    :payment, :as => :chargeable, :order => 'id DESC', :conditions => "payments.payment_type = '#{Payment::SUBSCRIPTION_PAYMENT_TYPE}'"
  accepts_nested_attributes_for :payment, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  has_many   :past_payments, :as => :chargeable, :class_name => 'Payment', :order => 'id DESC'
  
  validates_presence_of :payment, :unless => :free?
  validates_associated  :payment, :unless => :free?
  
  before_validation :clear_payment, :if => :free?
  before_validation :set_payment_amount, :unless => :free?
  validates_presence_of :free_reason, :if => :free?
  
  named_scope :current, :conditions => "status = 'active' OR 'past_due'"
  named_scope :newest_first, :order => "updated_at DESC"
  named_scope :active_on, lambda{|date|
    {:conditions => ["created_at <= ? AND (canceled_at IS NULL OR canceled_at > ?)", date.end_of_day, date.end_of_day]}
  }
  named_scope :activated_on, lambda{|date|
    {:conditions => ["created_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day]}
  }
  named_scope :paid, :conditions => "cost != 0.0"
  named_scope :free, :conditions => "cost = 0.0"
  
  attr_accessor :payment_not_required
  
  aasm_column :status
  aasm_initial_state :pending
  
  aasm_state :pending
  aasm_state :active,   :enter => :do_activate
  aasm_state :past_due, :enter => :do_payment_error
  aasm_state :canceled, :enter => :do_cancel
  
  aasm_event :activate do
    transitions :from => :pending, :to => :active, :guard => :is_enrolled?
    transitions :from => :past_due, :to => :active, :guard => :is_reconciled_and_updated?
    transitions :from => :active, :to => :active, :guard => :is_updated?
  end
  
  aasm_event :past_due do
    transitions :to => :past_due, :from => [:pending, :active, :past_due]
  end
  
  aasm_event :cancel do
    transitions :to => :canceled, :from => [:pending, :active, :past_due]
  end
  
  def self.change_in_members(start_date, finish_date)
    active_on(start_date).count - active_on(finish_date).count
  end
  
  # Is this a free membership
  def free?
    cost == 0.0 || payment_not_required
  end
  
  # Only consider active memberships and ones that are still in their grace period
  # to be actvie memberships.
  def current?
    active? || past_due?
  end
  
  def cancel!(reason = 'n/a')
    self.canceled_reason = reason
    self.cancel
    self.save
  end
  
  def recently_enrolled?
    @recently_enrolled
  end
  
  def recently_activated?
    @recently_activated
  end
  
  def recently_canceled?
    @recently_canceled
  end
  
  def recently_past_due?
    @recently_past_due
  end
  
  protected
    def do_activate
      return if active?
      capture_subscription_id unless has_subscription
      self.attempts = 0 # Reset the number of failed attempts. For comming from past_due
      self.canceled_at = nil
      self.canceled_reason = nil
      self.auto_cancel_at = nil
      user.update_attribute(:member, true)
      @recently_activated = true
    end
    
    def do_cancel
      cancel_arb if subscription_id
      self.canceled_at = Time.zone.now
      self.auto_cancel_at = nil
      user.update_attribute(:member, false)
      @recently_canceled = true
    end
    
    def do_payment_error
      record_attempt
      self.update_attribute(:auto_cancel_at, Time.zone.now + App.membership_grace_period.days) if auto_cancel_at.blank?
      @recently_past_due = true
    end
    
    def record_attempt
      self.attempts = self.attempts + 1
    end
    
    def capture_subscription_id
      self.subscription_id = (payment && payment.authorization_code)
    end
    
    # Is this membership enrolled in ARB if it needs to be?
    # if not try to process the payment
    def is_enrolled?
      is_enrolled = free? || active? || payment.process!
      is_enrolled && (@recently_enrolled = true)
    end
    
    def is_updated?
      free? || (subscription_id && payment && payment.update_subscription(subscription_id))
    end
    
    # Has this membership been reconciled successfully
    # and then has the payment information been updated with ARB
    def is_reconciled_and_updated?
      is_reconciled = reconcile_membership
      is_reconciled && is_updated?
    end
    
    # Attempt to Reconcile the membership
    def reconcile_membership
      reconciliation_payment                = payment.clone
      reconciliation_payment.status         = 'pending'
      reconciliation_authorization_code     = nil
      reconciliation_payment.payment_type   = Payment::SUBSCRIPTION_REDEMPTION_TYPE
      reconciliation_payment.card_number    = payment.card_number
      reconciliation_payment.security_code  = payment.security_code
      reconciliation_payment.build_billing_address(payment.billing_address.attributes)
      reconciliation_payment.save && reconciliation_payment.process!
    end
    
    def has_subscription
      self.free? || (self.subscription_id && self.subscription_id != 0)
    end
    
    def cancel_arb
      return unless self.subscription_id
      
      # Tell ARB to cancel this recurring subscription
      Payment.cancel_subscription(subscription_id)
    end
    
    def set_payment_amount
      payment.amount = cost unless payment.nil? || cost.blank?
    end
    
    def clear_payment
      self.payment = nil
    end
end