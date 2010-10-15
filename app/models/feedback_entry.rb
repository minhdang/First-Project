class FeedbackEntry < ActiveRecord::Base
  
  belongs_to :submisson
  
  def self.determine_feedback(stage,submission_id)
    if stage == 7
      submission = Submission.find(submission_id)
      if submission.user.member
        submission.pending_feedback
      end
    end
  end
  
end
