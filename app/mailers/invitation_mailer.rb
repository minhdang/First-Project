class InvitationMailer < ApplicationMailer
  
  def invitation_notification(invitation)
    recipients  "#{invitation.sent_to}"
    from        App.admin_email
    sent_on     Time.now
    subject     "Edison Nation - #{invitation.user.name} has invited you join our community for inventors"
    body        :user => invitation.user
  end
  
end
