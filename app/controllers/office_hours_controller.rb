class OfficeHoursController < ApplicationController
  
  layout 'dashboard'
  
  before_filter :login_required
  before_filter :find_user, :if => :logged_in?
  #before_filter :required_insider, :if => :logged_in?
  
  def index
    
  end
  
  def new
    @event = Event.find_current(params[:slug]).first 
  end
  
  def rsvp
    rsvp = Rsvp.create(params[:rsvp])
    rsvp.state = 'active'
    if rsvp.save
      flash['notice'] = "Your RSVP has been noted."
      redirect_to lounge_path
    else
      flash['notice'] = "There was an issues creating your RSVP. Please try again."
      render :action => 'new'
    end
    
  end
  
  def cancel_rsvp
    event = Event.find_current(params[:slug]).first 
    @user.rsvps.find_by_event_id(event.id).destroy
    flash['notice'] = "You're RSVP has been canceled. See you next time."
    redirect_to lounge_path
  end
  
  def video
    
  end
  
  def question
    respond_to do |format|
      format.js {
        message_body      = params[:body][:message]
        user_login        = params[:body][:user_login]
        user_first_name   = params[:body][:user_first_name]
        user_last_name    = params[:body][:user_last_name]
        user_email        = params[:body][:user_email] 
        QuestionMailer.deliver_message(message_body,user_login,user_first_name,user_last_name,user_email)
      }
    end
  end
  
  protected 
  
  def find_user
    @user = current_user
    unless @user.member?
      redirect_to lounge_path
    end
  end
  
end
