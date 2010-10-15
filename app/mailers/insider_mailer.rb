class InsiderMailer < ApplicationMailer
  
  def reminder(user)
    recipients    "#{user.email}"
    from          App.admin_email
    sent_on       Time.now
    body          :user => user
    subject       'Edison Nation - Account Reminder'
  end

end
