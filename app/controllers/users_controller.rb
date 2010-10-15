class UsersController < ApplicationController  
  before_filter :login_required, :only => [:edit, :update, :edit_avatar, :update_avatar, :destroy, :cancel_account]
  before_filter :find_user, :only => [:show, :edit, :update, :edit_avatar, :update_avatar, :destroy, :cancel_account]
  before_filter :handle_user, :only => [:show, :edit, :update, :edit_avatar, :update_avatar]
  before_filter :owner_required, :only => [:edit, :update, :edit_avatar, :update_avatar, :cancel_account, :destroy]
  before_filter :avatar_required, :only => [:edit_avatar, :update_avatar]
  
  skip_before_filter :hijack_request, :only => [:new, :create]
  
  def index
    @users = params[:q] ? User.search(params[:q], :conditions => {:active => true}, :page => params[:page], :per_page => App.per_page[:users]) :
                          User.active.paginate(:page => params[:page], :per_page => App.per_page[:users])
                          
    respond_to do |format|
      format.html
      format.txt { render :text => @users.map(&:name).join("\n") }
    end
  end

  # render new.rhtml
  def new
    session[:return_to] = params[:return_to] if params[:return_to] # allow us to redirect to somewhere specific after signup
        
    @step = params[:user] ? 2 : 1
    
    if @step == 1
      @user = User.new
    else
      # The user has submitted the first part of the
      # signup form. We should make sure that they
      # provided a name and a valid email address.
      @user = User.new(params[:user])
      @user.initial_signup = true
      @user.email = params[:user][:email]
      @step = 1 if !@user.valid? && params[:step_1]
    end
  end
  
  def show
    @notices = @user.created_notices.original.limit(10)
  end
  
  def edit
    @user.build_contact_information unless @user.contact_information
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.email = params[:user][:email]
    
    success = (@user && @user.valid?) ? @user.register! : false
    if success
      if @user.pending?
        flash[:notice] = "Thanks for signing up!  We have sent you an email with your activation link. "\
                         "You must check your email and click the activation link in order to activate and access your account."
        redirect_to login_path
      else
        flash[:notice] = "Thanks for signing up!"
        logout_keeping_session!
        self.current_user = @user
        redirect_back_or_default(user_path(@user))
      end
    else
      if @user.errors.on(:email) == 'has already been taken' && (existing = User.find_by_login_and_email(@user.login,@user.email)) && existing.pending?
        # This user is trying to create an account for an e-mail which has not been activated
        @user.password = nil
        UserMailer.deliver_signup_notification(@user)
        flash[:error]  = "This account has already been created but not activated. Another activation "\
                         "email has been sent to #{@user.email}. If you are still having trouble "\
                         "receiving your activation email, please check your spam folder or "\
                         "visit <a href='http://support.edisonnation.com'>support.edisonnation.com</a> to contact us."  
      elsif @user.errors.on(:email) == 'has already been taken' && (existing = User.find_by_login_and_email(@user.login,@user.email)) && existing.active?
        # This user is trying to create an account that already exists and has been activated.
        flash[:error]  = "This account already exists. If you are having trouble logging in to this "\
                         "account please <a href='/forgot_password'>click here to reset your password</a>, or "\
                         "visit <a href='http://support.edisonnation.com'>support.edisonnation.com</a> to contact us."
      else
        flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or " \
                         "visit <a href='http://support.edisonnation.com'>support.edisonnation.com</a> to contact us."
      end
      @step = 2
      render :new
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice]  = 'Your profile has been successfully updated.'
      flash[:notice] += " An email has been sent to #{@user.new_email} so that you may activate it." if @user.recently_updated_email?
      
      if @user.recently_updated_avatar?
        flash[:notice] += " Please crop your avatar below."
        redirect_to edit_avatar_user_path(@user)
      else
        redirect_to user_path(@user)
      end
    else
      @user.build_contact_information unless @user.contact_information
      render :action => :edit
    end
  end
  
  def edit_avatar
  end
  
  def update_avatar
    if @user.crop_avatar!(params[:crop_x], params[:crop_y], params[:crop_w], params[:crop_h])
      flash[:notice] = "Your avatar has been successfully cropped."
      redirect_to user_path(@user)
    else
      flash.now[:error] = "There was an error cropping your avatar. Please try again."
      render :action => :edit_avatar
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      # Activate a pending users account
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path
    when (!params[:activation_code].blank?) && user && user.active? && !user.new_email.blank?
      # Activate an active users new email address
      user.activate_new_email!
      flash[:notice] = 'Your email address has been successfully updated. Please log in below to continue.'
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    when params[:activation_code].length == 40 && user.nil?
      flash[:notice] = "You have already activated your account. Please log in below."
      redirect_to login_path
    else 
      flash[:error]  = "We couldn't find a user with that activation code – please try clicking the link from your email."
      redirect_back_or_default('/')
    end
  end
  
  def forgot_password
    @user = User.new
    return unless request.post?
    
    @user = User.find_by_email(params[:user][:email])
    if @user && @user.active?
      @user.forgot_password!
      flash[:notice] = "A reset link has been sent to #{@user.email}. Please follow that link to reset your password."
    elsif @user && @user.pending?
      UserMailer.deliver_signup_notification(@user)
      flash[:notice] = "The account associated with this email address has not been activated yet. An activation link has been sent to #{@user.email}. If you do not see your activation email, please check your Spam folder in your email or visit <a href='http://support.edisonnation.com'>support.edisonnation.com</a> for help."
    else
      flash[:error] = "An account with the email address #{params[:user][:email]} does not exist in our system."
    end
    
    redirect_back_or_default('/')
  end
  
  def reset_password
     @user = User.find_by_reset_code!(params[:reset_code])
     return unless request.post?
     
     @user.resetting_password = true
     if @user.update_attributes(params[:user])
       User.update_all('reset_code = NULL',"id = #{@user.id}")
       flash[:notice] = 'Your password has been successfully reset. Please log in below.'
       redirect_to login_path
     end
  end
  
  def destroy
    if params[:delete] && params[:delete].downcase.strip == 'delete'
      flash[:notice] = "Your account has been queued for deletion."
      @user.send_later(:delete!)
      logout_keeping_session!
      redirect_to signup_path
    else
      flash.now[:error] = "Your account was not deleted. Make sure to type the word 'delete'."
      render :cancel_account
    end
  end
  
  def cancel_account
  end

protected
  def find_user
    @user = User.find_by_login!(params[:id])
  end
  
  # Redirect to login if current user is not the owner of this page
  def owner_required
    is_owner = (current_user && current_user == @user)
    unless is_owner
      flash[:error] = 'You are not authorized to view this page.'
      redirect_to login_path
    end
    is_owner
  end
  
  # Redirect to the profile page if the user doesn't have an avatar
  def avatar_required
    has_avatar = @user.avatar?
    unless has_avatar
      flash[:error] = "No avatar was found for your account."
      redirect_to user_path(@user)
    end
    has_avatar
  end
end
