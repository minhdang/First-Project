class MoveObserver < ActiveRecord::Observer
  
  def after_save(move)
    move.submission.user.send_later(:notice!, move, public_notice = false) if move.recently_moved?
    
    # Send to notify the user that the status of his submission has changed
    LpsMailer.deliver_submission_moved(move.submission) if move.recently_moved?
  end
  
end