class Comment < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :idea
  belongs_to :submission
  
  validates_presence_of :user_id, :idea_id, :body
  
  attr_accessible :body, :submission_id
  
  default_scope :order => 'created_at ASC'
  named_scope :relevant_to, lambda {|submission|
    {
      :conditions => ["submission_id IS NULL OR submission_id = ?", submission.id],
      :order      => 'created_at ASC'
    }
  }
  
end
