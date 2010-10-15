class MessagesController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :handle_user

  def new
    @friends = @user.friends_with?(current_user)
    @message = @user.messages.new
    
    respond_to do |format|
      format.html {}
      format.js { render :action => :new, :layout => false }
    end
  end

  def create
    @message = @user.messages.new(params[:message])
    @message.sender = current_user
    
    if @message.save
      flash[:notice] = "Your message has been sent to #{@user.login} successfully."
      redirect_to user_path(@user)
    else
      render :action => :new
    end
  end

  protected
    def find_user
      @user = User.find_by_login!(params[:user_id]) if params[:user_id]
    end
end