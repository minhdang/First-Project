class TopicViewObserver < ActiveRecord::Observer
  
  def after_save(topic_view)
    topic_view.user.send_later(:notice!, topic_view, public_notice = false)
  end
  
end