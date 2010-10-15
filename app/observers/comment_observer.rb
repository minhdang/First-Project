class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    comment.user.send_later(:notice!, comment, public_notice = false)
  end
  
end