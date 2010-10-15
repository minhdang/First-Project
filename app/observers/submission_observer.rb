class SubmissionObserver < ActiveRecord::Observer

  def after_save(submission)
    # Send a Receipt to the user for their records
    if submission.recently_completed?
      # Don't want this block to run multiple times
      submission.instance_variable_set(:@recently_completed, false)
      
      # Evaluate for the pre-screen stage
      submission.apply_prescreen_filters! # Change to filters
      
      # Evaluate for the initial IP stage
      submission.apply_ip_filters!
      
      # Send out the submission receipt
      LpsMailer.deliver_submission_receipt(submission)
      
      # Send out a notice that the user submitted an idea
      submission.user.send_later(:notice!, submission)
    end
  end
  
end
