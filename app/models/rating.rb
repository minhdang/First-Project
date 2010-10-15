class Rating < ActiveRecord::Base
  Scale = 1..7
  
  belongs_to :user
  belongs_to :idea
  belongs_to :submission
  
  validates_presence_of :user_id, :idea_id, :submission_id, :rating
  validates_numericality_of :rating
  validates_inclusion_of :rating, :in => Scale, :message => "is not included in the rating scale of #{Scale.first} to #{Scale.last}"
  validates_uniqueness_of :submission_id, :scope => :user_id
  
  before_validation :capture_idea
  after_save :cache_associated_rating_averages
  
  named_scope :by_user, lambda {|user|
    {:conditions => {:user_id => user.id}}
  }
  named_scope :not_by_user, lambda {|user|
    {:conditions => ['user_id != ?', user.id]}
  }
  named_scope :for, lambda {|submission|
    {:conditions => {:submission_id => submission.id}}
  }
  
  attr_protected :user_id, :idea_id, :submission_id
  
  protected
    
    def capture_idea
      self.idea = submission.idea if submission
    end
    
    def cache_associated_rating_averages
      idea.cache_rating_average!
      submission.cache_rating_average!
    end
end
