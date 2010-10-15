class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user) if user.recently_registered?
  end

  def after_save(user)
    # Send a Activation notice if their account was just activated
    UserMailer.deliver_activation(user) if user.recently_activated?
    
    # Create the default friendship with 'enteam' account
    if user.recently_activated? && (enteam = User.find_by_login('enteam'))
      user.create_friendship_with_team unless enteam.blank? || enteam == self || user.friendship_with(enteam)
    end
    
    # Create a notice that this user joined Edison Nation
    user.send_later(:notice!,user,true) if user.recently_activated?
    
    # Send a change email address confirmation if the just tried to update their email address
    UserMailer.deliver_change_email_confirmation(user) if user.recently_updated_email?
    
    # Send a reset code so the user can reset their password
    UserMailer.deliver_forgot_password(user) if user.forgot_password?
  end
end
