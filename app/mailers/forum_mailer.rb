class ForumMailer < ApplicationMailer
  
  # Notify a user that is monitoring a topic that someone
  # has posted to that topic.
  def topic_monitor(user, post)
    setup_email(user)
    subject       "Edison Nation - #{post.user.login} posted on \"#{h(post.topic.title)}\""
    body          :user => user, :post => post
  end
  
  def spam_warning(post)
    recipients    App.admin_notifications_email
    from          App.admin_email
    sent_on       Time.now
    subject       "Edison Nation Robot - Post ##{post.id} was marked as spam"
    body          :post => post
  end
end