class InvitationObserver < ActiveRecord::Observer
  
  def after_create(invitation)
    InvitationMailer.deliver_invitation_notification(invitation)
  end
  
end
