class Submission < ActiveRecord::Base
  include AASM
  
  # Flash message the will be displayed when a user edits their idea and returns to the LPS dashboard
  UpdatedMessage  = 'Your submission was successfully updated. You can track your progress at any time by visiting this page.'
  
  LastStage = 8
  Stages = {
    1 => "Submission Received",
    2 => "Pre-Screen",
    3 => "Initial IP Review",
    4 => "Research & Design",
    5 => "Final Consideration",
    6 => "Final IP Review",
    7 => "Finalist",
    8 => "Success"
  }
  Statuses = {
    1 => "Application Complete",
    2 => "Passed Pre Screen",
    3 => "Passed IP Review",
    4 => "Passed Search Criteria",
    5 => "Passed Final Consideration",
    6 => "Passed Uniqueness",
    7 => "Finalist",
    8 => "Success!"
  }
  
  belongs_to :live_product_search
  belongs_to :idea
  belongs_to :user
  belongs_to :coupon
  
  has_one :feedback_entry
  
  has_one :contact_information, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contact_information, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  has_one :payment, :as => :chargeable
  accepts_nested_attributes_for :payment, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  has_many :answers, :dependent => :destroy
  accepts_nested_attributes_for :answers
  
  has_many :ratings, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  
  has_many :moves, :dependent => :destroy
  has_one  :last_move, :class_name => 'Move', :order => 'move_to DESC'
  
  has_many :filters,            :through => :live_product_search
  has_many :prescreen_filters,  :through => :live_product_search, :class_name => 'Filter', :conditions => {:stage => 2}
  has_many :ip_filters,         :through => :live_product_search, :class_name => 'Filter', :conditions => {:stage => 3}
  
  after_save    :update_counter_cache_on_idea
  after_destroy :update_counter_cache_on_idea
  
  validates_presence_of   :live_product_search_id, :idea_id, :stage, :visible_stage
  validates_uniqueness_of :idea_id, :scope => :live_product_search_id
  validates_uniqueness_of :first, :scope => :idea_id, :if => :first?
  
  validates_acceptance_of :agree_to_terms, :agree_to_age_requirements, :agree_to_no_feedback,
                          :accept => true, :if => :accepting_terms
  validates_presence_of   :signature, :if => :accepting_terms
  
  validates_presence_of   :contact_information, :if => :accepting_terms
  validates_associated    :contact_information, :if => :accepting_terms
  
  validates_acceptance_of :agree_to_submission_fee, :accept => true, :if => :accepting_terms, :unless => :free?
  validates_presence_of   :payment, :if => :accepting_terms, :unless => :free?
  validates_associated    :payment, :if => :accepting_terms, :unless => :free?
  before_validation       :set_payment_amount, :if => :payment, :unless => :free?
  
  validates_format_of :signature, :with => /^\/.*\/$/, :allow_blank => true
  
  named_scope :for, lambda {|lps|
    {:conditions => {:live_product_search_id => lps.id}}
  }
  named_scope :archived, lambda {|bool|
    {:conditions => {:archived => bool}}
  }
  named_scope :limit, lambda {|max|
    {:limit => max}
  }
  named_scope :completed_on, lambda {|date|
    {:conditions => ['submissions.completed_at BETWEEN ? AND ?', date.beginning_of_day.utc, date.end_of_day.utc]}
  }
  named_scope :completed_by, lambda {|date|
    {:conditions => ['submissions.completed_at < ?', date.end_of_day.utc]}
  }
  named_scope :completed_after, lambda {|date|
    {:conditions => ['submissions.completed_at > ?', date.end_of_day.utc]}
  }
  named_scope :original, lambda {|*bool|
    {:conditions => {:first => (bool.first.nil? ? true : bool.first)}}
  }
  named_scope :alive, lambda {|*bool|
    {:conditions => {:alive => (bool.first.nil? ? true : bool.first)}}
  }
  named_scope :dead, :conditions => {:alive => false}
  named_scope :at_stage, lambda {|stage|
    {:conditions => {:stage => stage}}
  }
  named_scope :pending_at_stage, lambda {|stage|
    {:conditions => {:alive => true, :stage => (stage.to_i - 1)}}
  }
  named_scope :alive_at_stage, lambda {|stage|
    {:conditions => {:alive => true, :stage => stage.to_i}}
  }
  named_scope :dead_at_stage, lambda {|stage|
    {:conditions => {:alive => false, :stage => stage.to_i}}
  }
  named_scope :except, lambda {|*submissions|
    {:conditions => ['submissions.id NOT IN (?)', submissions.map(&:id)]}
  }
  named_scope :green_at_stage, lambda {|stage|
    {:conditions => [
      "(alive = ? AND stage = ?)" +
      " OR "                      +
      "(alive = ? AND stage = ?)",
      true,   stage,
      false,  stage + 1
    ]}
  }
  
  # Advance Searching Named Scopes 
  named_scope :prototype, lambda {|*args|
    bool = args.empty? ? true : args.first
    {
      :joins      => :idea,
      :conditions => {:ideas => {:prototype => bool}}
    }
  }
  named_scope :issued_patent, :joins => {:idea => :patents},  :select => 'DISTINCT submissions.id, submissions.*', :conditions => ['patents.stage = ?', Patent::StageIssued]
  named_scope :pending_patent, :joins => {:idea => :patents}, :select => 'DISTINCT submissions.id, submissions.*', :conditions => ['patents.stage = ?', Patent::StagePending]

  named_scope :attachments, lambda {|*args|
    bool = args.empty? ? true : args.first
    {
      :joins => :idea,
      :conditions => (bool ? "ideas.attachments_count > 0" : "ideas.attachments_count == 0")
    }
  }
  named_scope :average_rating_gte, lambda {|rating|
    {:conditions => ['submissions.average_rating >= ?', rating]}
  }
  named_scope :average_rating_lte, lambda {|rating|
    {:conditions => ['submissions.average_rating <= ?', rating]}
  }
  named_scope :category, lambda {|category_id_or_name|
    category = IdeaCategory.find(:first, :conditions => ['id = ? OR name = ?', category_id_or_name, category_id_or_name])
    {
      :joins => :idea,
      :conditions => ['ideas.category_id = ?', category.id]
    }
  }
  
  
  
  before_validation_on_create :capture_user
  before_create :generate_key
  
  attr_accessor :accepting_terms, :fee
  attr_protected :accepting_terms
  
  attr_protected  :live_product_search_id, :live_product_search, :idea_id, :idea, :user_id, :key, :alive, 
                  :stage, :visible_stage, :average_rating, :first, :state, :contact_information, :payment, :fee,
                  :agree_to_terms, :agree_to_age_requirements, :agree_to_no_feedback, :agree_to_submission_fee, :signature,
                  :agreement_version
                  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :complete, :enter => :do_complete

  aasm_event :complete do
    transitions :from => :pending, :to => :complete, :guard => :payment_processed?
  end
  
  HUMAN_ATTRIBUTES = {  
    :answers_base    => ''  
  }  
  def self.human_attribute_name(attr)  
    HUMAN_ATTRIBUTES[attr.to_sym] || super  
  end
  
  # Thinking Sphinx Index
  define_index do
    # fields
    indexes [user.first_name, user.last_name], :as => :user_name
    indexes user.login, :as => :login
    indexes idea.title, :as => :title
    
    # attributes
    has live_product_search_id
  end
  
  # Remove leading an trailing whitespace when accepting a signature
  def signature=(sig)
    self[:signature] = sig.strip
  end
  
  def to_param
    key
  end
  
  def alive_at?(s)
    stage == s && alive?
  end
  
  def dead_at?(s)
    stage == s && dead?
  end
  
  def move_pending?
    visible_stage != stage
  end
  
  def dead?
    !alive?
  end
  
  # Pass the submission on to the next stage
  def pass!(options = {})
    return(false) if dead? || !next_stage
    move_to!(stage+1, pass = true, options)    
  end
  
  # Fail the submission on the next stage
  def fail!(options = {})
    return(false) if dead? || !next_stage
    move_to!(stage+1, pass = false, options)
  end
  
  # Move the submission to a certain stage and pass/fail it
  def move_to!(stage, pass = true, options = {})
    self.stage = stage
    self.alive = pass
    move = moves.build do |m|
      m.move_to     = stage
      m.user        = options[:user]
    end
    transaction do
      move.save!
      FeedbackEntry.determine_feedback(stage, self.id)
      Submission.update_all("stage = #{stage}, alive = #{pass ? 1 : 0}", "id = #{self.id}") # Don't update the updated_at column
    end
  end
  
  # Will this submission be the idea's first
  # complete submission when marked as complete!
  def will_be_first?
    !idea.first_submission
  end
  
  def fee
    @fee ||= calculate_fee
  end
  
  def free?
    fee == 0.0
  end
  
  def calculate_fee
    without_coupon = fee_before_coupon
    coupon ? coupon.applied_price(without_coupon) : without_coupon
  end
  
  def fee_before_coupon
    return App.idea_submission_cost unless user
    user.reload # The user may have just upgraded to gole membership

    if live_product_search.submission_fee == 0.0
      0.0
    elsif first? || will_be_first?
      user.member? ? App.member_idea_submission_cost : App.idea_submission_cost
    else
      user.member? ? 0.0 : App.idea_submission_cost
    end

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
  
  def status_for_stage(s)
    return 'pending' if passed_stage?(s).nil?
    passed_stage?(s) ? 'passed' : 'failed'
  end
  
  def status_for_visible_stage(s)
    return 'pending' if passed_visible_stage?(s).nil?
    passed_visible_stage?(s) ? 'passed' : 'failed'
  end
  
  def passed_stage?(s)
    return nil if s > stage
    s < stage || alive?
  end
  
  def passed_visible_stage?(s)
    return nil if s > visible_stage
    s < visible_stage || visible_stage < stage || alive?
  end
  
  def next_stage
    return nil if stage == LastStage
    stage + 1
  end
  
  def next_visible_stage
    return nil if !passed_visible_stage?(visible_stage) || visible_stage == LastStage
    visible_stage + 1
  end
  
  def removeable?
    ![7,8].include?(visible_stage) || dead_at?(visible_stage)
  end
  
  def archiveable?
    !passed_visible_stage?(visible_stage) && !archived?
  end
  
  def archive!
    return false unless archiveable?
    update_attribute(:archived, true)
  end
  
  def under_review?
    alive? && stage != LastStage
  end
  
  def status
    return 'Not selected for this search' unless passed_visible_stage?(visible_stage)
    Statuses[visible_stage]
  end
  
  # Returns the Document::Version that the inventor agreeed to
  def agreement
    Document.innovator_agreement && Document.innovator_agreement.versions.find_by_version(agreement_version)
  end
  
  def recently_completed?
    @recently_completed
  end
  
  def set_protected_term_attributes(params)
    self.accepting_terms            = true
    self.agree_to_terms             = params[:agree_to_terms]
    self.agree_to_age_requirements  = params[:agree_to_age_requirements]
    self.agree_to_no_feedback       = params[:agree_to_no_feedback]
    self.agree_to_submission_fee    = params[:agree_to_submission_fee]
    self.signature                  = params[:signature]
    self.agreement_version          = params[:agreement_version]
  end
 
  # Build answers for each custom question the LPS has
  def build_answers
    return unless live_product_search
    
    live_product_search.questions.each do |q|
      answers.build(:question => q) unless self.answers.for_question(q).any?
    end
  end
  
  def answer_for(question)
    self.answers.for_question(question).first
  end
  
  # Track the average rating
  def cache_rating_average!
    avg = ratings.average(:rating)
    Submission.update_all("average_rating = #{avg}","id = #{self.id}") # Don't update timestamps
  end
  
  # Return a csv formated row
  def to_csv_row
    row  = []
    row << key
    row << idea.title
    row << user.name
    row << "https://www.edisonnation.com/admin/live_product_searches/#{live_product_search.to_param}/submissions/#{to_param}"
    row << (under_review? ? "Pending at S#{next_stage}" : "#{alive? ? 'Alive' : 'Dead'} at S#{stage}")
    row << (idea.patent_pending? ? 'Y' : 'N')
    row << (idea.patent_issued?  ? 'Y' : 'N')
    row << (idea.prototype?      ? 'Y' : 'N')
    row << idea.attachments_count
    row += ratings.map(&:rating)
    row.map{|node| "\"#{node.to_s.strip.gsub(',','').gsub('"','`')}\""}.join(',')
  end
  
  def apply_prescreen_filters!
    apply_filter_set(prescreen_filters) if alive? && next_stage == 2
    
  end
  
  def apply_ip_filters!
    apply_filter_set(ip_filters) if alive? && next_stage == 3
  end
  
  
  def feedback_complete
    self.feedback = 'complete'
    self.save
  end
  
  def pending_feedback
    self.feedback = 'pending'
    self.save
  end
  
  def save_default_feedback
    feedback = FeedbackTemplate.first
    feedback_entry = FeedbackEntry.new
    feedback_entry.title = feedback.title
    feedback_entry.body  = feedback.body
    feedback_entry.save 
    self.feedback_entry = feedback_entry
    self.feedback_complete
  end
  
  protected
    
    
    
    def capture_user
      self.user = idea.user if idea
    end
    
    def generate_key
      self.key = "#{live_product_search.key}-#{idea.id}" if live_product_search && idea
    end
    
    def set_payment_amount
      payment.amount = fee if payment
    end
    
    def payment_processed?
      return true if free? || (payment && payment.approved?)
      
      self.fee = calculate_fee # Recalculate the fee
      set_payment_amount       # Update the payment amount
      payment && payment.process!
    end
    
    def do_complete
      self.completed_at   = Time.now
      self.first          = true if will_be_first?
      coupon.redeem! if coupon
      @recently_completed = true
    end
    
    def update_counter_cache_on_idea
      idea.update_attribute(:submissions_count, idea.submissions.complete.count)
    end
    
    def apply_filter_set(filter_set)
      if filter_set.all? {|filter| filter.pass?(self) }
        pass!
      else
        fail!
      end
    end


end
