class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    UserMailer.deliver_message(message)
  end
end
