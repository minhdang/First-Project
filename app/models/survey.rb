class Survey < ActiveRecord::Base
  include AASM
  
  acts_as_url :title
  formats_attributes :landing_page
  has_attached_file :landing_page_header
  
  has_many :questions, :class_name => 'SurveyQuestion', :order => 'position', :dependent => :destroy
  has_many :responses, :class_name => 'SurveyResponse', :dependent => :destroy
  
  belongs_to :document
  
  validates_presence_of :title, :deadline
  
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
    url
  end
  
  def build_response
    response = responses.new
    questions.each do |question|
      response.answers.build(:question => question)
    end
    response
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
  
  def current?
    published? && !past_deadline? && (launch.nil? || launch < Time.zone.now)
  end
  
  protected
  
    def do_publish
      self.launch ||= Time.zone.now
    end
    
end
