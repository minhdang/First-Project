class PostObserver < ActiveRecord::Observer
  
  def after_create(post)
    post.topic.monitoring_users.each do |monitor|
      ForumMailer.deliver_topic_monitor(monitor, post) unless monitor == post.user
    end
    
    # Create a notice
    post.user.send_later(:notice!,post,true)
  end
  
  def after_update(post)
    ForumMailer.deliver_spam_warning(post) if post.spammed?
  end
  
end