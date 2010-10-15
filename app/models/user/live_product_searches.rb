class User
  
  has_many :ideas, :order => 'complete ASC, created_at DESC'
  has_many :submissions, :order => 'state DESC, archived, updated_at DESC'
  has_many :ratings
  has_many :comments
  
  has_one  :latest_submission, :class_name => 'Submission', :conditions => {:state => 'complete'}, :order => 'submissions.completed_at DESC'
  has_one  :latest_contact_information, :through => :latest_submission, :source => :contact_information, :order => 'submissions.completed_at DESC'
  
  def rating_for(submission)
    ratings.for(submission).first
  end
end