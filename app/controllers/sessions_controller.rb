# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  skip_before_filter :hijack_request
  
  def show
    redirect_to login_path
  end

  # render new.rhtml
  def new
    if params[:return_to]
      (redirect_to(params[:return_to]) and return(false)) if logged_in?
      session[:return_to] = params[:return_to]    
    end
    
    @user = User.new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      
      # Set some user cookies - used for javascript
      cookies[:login] = user.login
      
      user.log(request)
      
      redirect_back_or_default('/')
      flash[:notice] = "Welcome! You have been logged in successfully."
    else
      note_failed_signin
      
      # Let the user know if there account has not been activated yet
      # - this should keep all the support emails about reseting passwords
      #   to a minimum. Hopefully they're smart enough to understand this!
      if existing_user = User.authenticate(params[:login], params[:password], :pending)
        UserMailer.deliver_signup_notification(existing_user)
        flash[:error] += " Your account has not been activated yet. Another activation email has been sent to "\
                         "#{existing_user.email}. Please check your email for activation instructions. "\
                         "If you do not see your activation email, please check your Spam folder in your email. or visit "\
                         " http://support.edisonnation.com for help "
      end 
      
      @login       = params[:login]
      @remember_me = params[:remember_me]
      redirect_to login_path
    end
  end

  def destroy
    logout_killing_session!
    cookies.delete(:login)
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'."
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def set_preferences_cookie(preferences)
    preferences = preferences.get_hash_for_cookies
    preferences.each do |key, value|
        cookies[key] = value unless value.blank? && !cookies[key]
    end
  end
  
  def destroy_preferences_cookie
    preferences = Preferences.new.get_hash_for_cookies
    preferences.each do |key, value|
      cookies.delete(key)
    end
  end
end
