class LiveProductSearch < ActiveRecord::Base
  include AASM
  
  formats_attributes :description, :requirements, :submission_fee_details, :landing_page
  
  has_attached_file :landing_page_header
  validates_attachment_content_type :landing_page_header, :content_type => /image/, :message => 'is not an image.'
  
  belongs_to :sponsor
  belongs_to :document
  
  has_many :questions, :order => 'position'
  has_many :submissions, :conditions => {:state => 'complete'}
  has_many :ideas, :through => :submissions
  
  has_many :filters
  has_many :prescreen_filters,  :class_name => 'Filter', :conditions => {:stage => 2}
  has_many :ip_filters,         :class_name => 'Filter', :conditions => {:stage => 3}
  
  validates_presence_of :sponsor, :title, :deadline
  validates_uniqueness_of :token
  validates_uniqueness_of :landing_page_url, :allow_blank => true
  
  before_validation_on_create :generate_token
  after_create :generate_key
  
  attr_protected :state
  
  default_scope :order => "launch DESC"
  
  named_scope :current, lambda {
    {:conditions => ["state = ? AND deadline > ? AND (launch IS NULL OR launch < ?)", 'published', Time.zone.now, Time.zone.now]}
  }
  named_scope :launched_on, lambda{|date|
    {:conditions => ['launch IS NOT NULL AND launch BETWEEN ? AND ?', date.beginning_of_day.utc, date.end_of_day.utc]}
  }
  named_scope :launched_by, lambda{|date|
    {:conditions => ['launch IS NOT NULL AND launch < ?', date.end_of_day.utc]}
  }
  
  aasm_column :state
  aasm_initial_state :initial => :draft
  aasm_state :draft
  aasm_state :published, :enter => :do_publish
  aasm_state :archived
  aasm_state :deleted
  
  aasm_event :draft do
    transitions :from => [:published,:archived], :to => :draft
  end
  
  aasm_event :publish do
    transitions :from => [:draft,:archived], :to => :published
  end
  
  aasm_event :archive do
    transitions :from => [:draft,:published], :to => :archived
  end
  
  aasm_event :delete do
    transitions :from => [:draft, :published, :archived], :to => :deleted
  end
  
  def to_param
    key # EN1234
  end
  
  def available_states
    return [:deleted] if deleted?
    available = [:published, :archived, :deleted]
    available.unshift(:draft) if published? || draft?
    available.delete(:deleted) if new_record?
    available.delete(:archived) if new_record?
    available
  end
  
  def move_to_state(s)
    s = s.to_sym
    case s
    when :draft
      self.draft unless draft?
    when :published
      self.publish unless published?
    when :archived
      self.archive unless archived?
    when :deleted
      self.delete unless deleted?
    end
  end
  
  # Normalize deadline to the end of the day if a date or string is given
  def deadline=(day_or_time)
    if day_or_time.is_a?(Date) || day_or_time.is_a?(String)
      day_or_time = Time.zone.parse(day_or_time) if day_or_time.is_a?(String)
      day_or_time = day_or_time.end_of_day
    end
    self[:deadline] = day_or_time
  end
  
  def past_deadline?
    Time.zone.now > deadline
  end
  
  def past_grace_period?
    Time.zone.now > deadline + App.lps[:grace_period].days
  end
  
  def do_publish
    self.launch ||= Time.zone.now
  end
  
  # Returns false if the search is still open or within the grace period
  # OR if the user has supplied the correct token to submit after deadline
  def closed?(passed_token = nil)
    past_grace_period? && token != passed_token
  end
  
  def current?
    published? && !past_deadline? && (launch.nil? || launch < Time.zone.now)
  end
  
  def free?
   return true if self.submission_fee == 0.0
  end
  
  protected
    
    def generate_key
      generated_key = "#{sponsor.initials}#{id}"
      update_attribute(:key, generated_key)
    end
    
    def generate_token
      while(token.blank?)
        potential_token = Digest::SHA1.hexdigest(Time.now.usec.to_s).upcase[0...8]
        self.token = potential_token unless LPS.exists?(:token => token)
      end
    end
  
end
# alias liveProductSearch to LPS
# LPS.find vs. LiveProductSearch.find
::LPS = LiveProductSearch


