class UserMailer < ApplicationMailer  
  # Sent when a user first registers on the site
  def signup_notification(user)
    setup_email(user)
    subject         'Edison Nation - Please activate your new account'
  end
  
  # Sent when the user has clicked on the activation link
  def activation(user)
    setup_email(user)
    subject         'Edison Nation - Your account has been activated!'
  end
  
  # Sent when the user updates their email
  def change_email_confirmation(user)
    setup_email(user)
    recipients      "#{user.new_email}"
    subject         'Edison Nation - Confirm email address change'
    body            :user => user, :url => "#{site}/activate/#{user.activation_code}"
  end
  
  def membership_cancellation(user)
    setup_email(user)
    subject         'Edison Nation - Your account has been downgraded'
  end
  
  def membership_activation(user)
    setup_email(user)
    subject         'Edison Nation - Thank you for becoming an Edison Insider'
  end
  
  def update_membership_cc_alert(user)
    setup_email(user)
    subject         'Edison Nation - There was an error processing your billing information'
  end
  
  def forgot_password(user)
    setup_email(user)
    subject         'Edison Nation - Finish resetting your password'
  end

  def message(message)
    bccs            = [message.user.email]
    bccs            << message.sender.email if message.cc?
    bcc             bccs
    from            App.admin_email
    sent_on         Time.now
    subject         "Edison Nation - #{message.sender.name} has sent you a message"
    body            :message => message
  end
end
