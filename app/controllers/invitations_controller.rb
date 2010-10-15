class InvitationsController < ApplicationController
  
  before_filter :login_required
  
  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.user = current_user
    
    if @invitation.save
      flash[:notice] = "Your invitation has been sent to #{@invitation.sent_to}."
    elsif existing = Invitation.find_by_sender_id_and_sent_to(current_user.id,params[:invitation][:sent_to])
      InvitationMailer.deliver_invitation_notification(existing)
      flash[:notice] = "Another invitation has been sent to #{@invitation.sent_to}"
    else
      flash[:error] = "Your invitation could not be sent. Please make sure that you have entered a valid email address."
    end
    
    redirect_to dashboard_path
  end

end
