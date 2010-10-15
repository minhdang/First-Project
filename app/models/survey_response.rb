class SurveyResponse < ActiveRecord::Base
  include AASM
  
  belongs_to :survey
  belongs_to :user
  
  belongs_to :document
  
  has_many   :answers, :class_name => 'SurveyAnswer', :foreign_key => :response_id, :dependent => :destroy
  accepts_nested_attributes_for :answers
  
  has_one :contact_information, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contact_information, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  has_one :payment, :as => :chargeable
  accepts_nested_attributes_for :payment, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  validates_presence_of :survey_id
  
  validates_acceptance_of :agree_to_terms, :if => :accepting_terms?, :accept => true
  
  validates_presence_of   :contact_information, :if => :accepting_terms?
  validates_associated    :contact_information, :if => :accepting_terms?
  
  validates_acceptance_of :agree_to_submission_fee, :accept => true, :if => :accepting_terms?, :unless => :free?
  validates_presence_of   :payment, :if => :accepting_terms?, :unless => :free?
  validates_associated    :payment, :if => :accepting_terms?, :unless => :free?
  before_validation       :set_payment_amount, :if => :payment, :unless => :free?
  
  named_scope :for, lambda {|survey|
    {:conditions => {:survey_id => survey.id}}
  }
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :complete, :enter => :do_complete

  aasm_event :complete do
    transitions :from => :pending, :to => :complete, :guard => :payment_processed?
  end
  
  def versioned_document
    document.versions.find_by_version(document_version) if document && document_version
  end
  
  def under_review?
    selected.nil?
  end
  
  def not_selected?
    !under_review? && !selected?
  end
  
  def status
    if under_review?
      'Your submission is still being considered'
    elsif selected?
      'Congratulations, your submission was selected'
    elsif not_selected?
      "We're sorry, your submission was not selected"
    end
  end
  
  def title
    answers.first ?
      answers.first.value :
      ''
  end
  
  def free?
    if user.member?
      (survey.submission_fee_members && survey.submission_fee_members.zero?) || survey.submission_fee.zero?
    else
      survey.submission_fee.zero?
    end
  end
  
  def submission_fee
    (user.reload && user.member? && survey.submission_fee_members) ?
      survey.submission_fee_members :
      survey.submission_fee
  end
  
  def infer_contact_information
    latest_contact_information = user.latest_contact_information && user.latest_contact_information.clone
    
    if latest_contact_information
      self.contact_information = latest_contact_information
    else
      contact_info = {}
      contact_info[:first_name]    = user.first_name
      contact_info[:last_name]     = user.last_name
      contact_info[:email]         = user.email
      
      if user.contact_information
        contact_info[:phone]       = user.contact_information.phone
        contact_info[:address_1]   = user.contact_information.address_1
        contact_info[:address_2]   = user.contact_information.address_2
        contact_info[:city]        = user.contact_information.city
        contact_info[:state]       = user.contact_information.state
        contact_info[:postal_code] = user.contact_information.postal_code
        contact_info[:country]     = user.contact_information.country
      end
      build_contact_information(contact_info)
    end
  end
  
  def accepting_terms!
    @accepting_terms = true
  end
  
  def accepting_terms?
    @accepting_terms
  end
  
  def recently_completed?
    @recently_completed
  end
  
  protected
  
    def payment_processed?
      return true if free? || (payment && payment.approved?)

      set_payment_amount       # Update the payment amount
      payment && payment.process!
    end
    
    def set_payment_amount
      payment.amount = submission_fee if payment && payment.amount.nil?
    end
    
    def do_complete
      self.completed_at   = Time.now
      @recently_completed = true
    end
  
end
