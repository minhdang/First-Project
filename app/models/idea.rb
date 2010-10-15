class Idea < ActiveRecord::Base
  # Flash message the will be displayed when a user edits their idea and returns to the LPS dashboard
  UpdatedMessage = 'Your idea was successfully saved. You can view and edit your idea at any time by visiting this page.'
  DeletedMessage = 'Your idea and all of its submissions were permanatly removed from the database.'
  
  belongs_to :user
  belongs_to :category, :class_name => 'IdeaCategory', :counter_cache => true
  
  has_many :patents, :dependent => :destroy
  has_many :issued_patents, :class_name => 'Patent', :conditions => {:stage => Patent::StageIssued}
  has_many :pending_patents, :class_name => 'Patent', :conditions => {:stage => Patent::StagePending}
  accepts_nested_attributes_for :issued_patents, :allow_destroy => true, :reject_if => proc{|attrs| attrs.values.all?(&:blank?)}
  accepts_nested_attributes_for :pending_patents, :allow_destroy => true, :reject_if => proc{|attrs| attrs.values.all?(&:blank?)}
  
  has_many :disclosures, :dependent => :destroy
  accepts_nested_attributes_for :disclosures, :allow_destroy => true,
    :reject_if => proc{|attrs| attrs.values.all?{|v| v.blank? || v == '0'} }
    
  has_many :contributors, :dependent => :destroy
  accepts_nested_attributes_for :contributors, :allow_destroy => true,
    :reject_if => proc{|attrs| attrs['details'].blank? &&
                  attrs['contact_information_attributes'].reject{|k,v| k=='country'}.values.all?(&:blank?)}
                  
  has_many :attachments, :class_name => '::Attachment', :dependent => :destroy
  has_many :temp_attachments
  
  has_many :submissions, :dependent => :destroy
  has_one  :first_submission, :class_name => 'Submission', :conditions => {:first => true}
  has_one  :latest_submission, :class_name => 'Submission', :conditions => {:state => 'complete'}, :order => 'submissions.completed_at DESC'
  
  has_many :live_product_searches, :through => :submissions, :conditions => {:submissions => {:state => 'complete'}}
  
  has_one  :latest_contact_information, :through => :latest_submission, :source => :contact_information
  
  has_many :ratings
  has_many :comments
  
  validates_presence_of :user_id, :title, :detailed_description, :innovation,
                        :problem, :target_user, :target_customer, :category_id
  
  attr_protected :complete, :ip_complete
  
  named_scope :complete, :conditions => {:complete => true}
  named_scope :available_for, lambda {|lps|
    {
      :conditions => ["ideas.id NOT IN (SELECT idea_id FROM submissions WHERE submissions.state = 'complete' AND submissions.live_product_search_id = ?)", lps.id]
    }
  }
  
  # Advance Searching Named Scopes 
  named_scope :submitted_to, lambda {|lps|
    {
      :joins      => :submissions,
      :conditions => {:submissions => {:live_product_search_id => (lps.kind_of?(LiveProductSearch) ? lps.id : lps), :state => 'complete'}}
    } 
  }
  named_scope :prototype, lambda {|*args|
    bool = args.empty? ? true : args.first
    {:conditions => {:prototype => bool}}
  }
  named_scope :issued_patent, :joins => :patents, :conditions => {
    :patents => {:stage => Patent::StageIssued}
  }
  named_scope :pending_patent, :joins => :patents, :conditions => {
    :patents => {:stage => Patent::StagePending}
  }
  named_scope :attachments, lambda {|*args|
    bool = args.empty? ? true : args.first
    {
      :conditions => (bool ? "ideas.attachments_count > 0" : "ideas.attachments_count == 0")
    }
  }
  named_scope :average_rating_gte, lambda {|rating|
    {:conditions => ['ideas.average_rating >= ?', rating]}
  }
  named_scope :average_rating_lte, lambda {|rating|
    {:conditions => ['ideas.average_rating <= ?', rating]}
  }
  named_scope :category, lambda {|category_id_or_name|
    category = IdeaCategory.id_or_name_eq(category_id_or_name).first
    {
      :conditions => {:category_id => category.id}
    }
  }
    
  # Thinking Sphinx Index
  define_index do
    # fields
    indexes [user.first_name, user.last_name], :as => :user_name
    indexes user.login, :as => :login
    indexes title, :as => :title
  end
  
  
  def price=(price)
    price.gsub!(/[^\d\.]/, '') if price.kind_of?(String)
    self[:price] = price
  end
  
  def ip_complete!
    update_attribute(:ip_complete, true) unless ip_complete?
  end
  
  def complete!
    update_attribute(:complete, true) unless complete?
  end
  
  # Return the submission for a given LPS
  def submission_for(lps)
    submissions.find_or_create_by_live_product_search_id(lps.id)
  end
  
  # Track the average rating
  def cache_rating_average!
    avg = ratings.average(:rating)
    update_attribute(:average_rating, avg)
  end
  
  def removeable?
    return true unless submissions.complete.any?
    submissions.complete.all?(&:removeable?)
  end
  
  # Return a csv formated row
  def to_csv_row
    row  = []
    row << id
    row << title
    row << user.name
    row << "https://www.edisonnation.com/admin/ideas/#{to_param}"
    row << (star?           ? 'Y' : 'N')
    row << (patent_pending? ? 'Y' : 'N')
    row << (patent_issued?  ? 'Y' : 'N')
    row << (prototype?      ? 'Y' : 'N')
    row << attachments_count
    row += ratings.map(&:rating)
    row.map{|node| "\"#{node.to_s.strip.gsub(',','').gsub('"','`')}\""}.join(',')
  end
  
end
