# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SslRequirement
  
  helper :all # include all helpers, all the time
  helper_method :current_page
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e508f545a847ff79fb881e137b0dc20d'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  filter_parameter_logging :password, :card_number, :security_code

  before_filter :set_locale
  
  def set_locale
    I18n.locale = params[:locale] 
  end
  
  protected
    def render_optional_error_file(status_code)
      if status_code == :not_found
        render_404 and return
      else
        super
      end
    end
    
    def render_404
      respond_to do |format|
        format.html { render :template => 'errors/error_404', :layout => 'application', :status => 404 }
        format.all  { render :nothing => true, :status => 404 }
      end
      true
    end
  
   def render_holder
     respond_to do |format|
       format.html { render :template => 'system/insider', :layout => false}
     end
   end
  
    def membership_required_notice; end
    def membership_required
      has_membership = current_user.member?
      unless has_membership
        flash[:notice] = membership_required_notice if membership_required_notice
        redirect_to new_membership_path
      end
      has_membership
    end
    
    def current_page
      @page ||= if params[:page].blank? then 1
                elsif params[:page] == 'last' then :last
                else params[:page].to_i end
    end
    
    def user_preferences
      @user_preferences ||= ((logged_in? && current_user.preferences)  || Preferences.new)
    end
    
    def per_page
      user_preferences.per_page
    end
    
    # Shopping Cart object - Session backed
    def find_cart
      @store ||= Store.find_by_url!(params[:store_id])
      @cart ||= Cart.new(@store, session, current_user)
    end
    
    # Handle Closed Live Product Searches
    def handle_closed_lps
      session[:token] = params[:token] if params[:token]
      open = !@lps.closed?(session[:token])
      unless open
        flash[:error] = 'This search is closed. We are no longer accepting submissions for this search.'
        redirect_to live_product_search_path(@lps)
      end
      return open
    end
    
    # Are there any flash messages to display for this request?
    # This is usefull for skipping action caching if we are going
    # to be displaying a flash message.
    def flash_message?
      flash.now[:notice] || flash.now[:error] || flash.now[:success]
    end
    
    # Give h style html formatting to the controller
    # Used mainly to escape user data in flash messages
    def h(string)
      CGI.escapeHTML(string)
    end
    
    # Returns true if the current action is supposed to run as SSL
    def ssl_required?
      ['staging','production'].include?(Rails.env) && (self.class.read_inheritable_attribute(:ssl_required_actions) || []).include?(action_name.to_sym)
    end
    
    def handle_user
      return true if @user.active?
      if @user.suspended?
        render :template => 'errors/suspended'
        return false
      else
        raise ActiveRecord::RecordNotFound
      end
    end
    
    def redirect_to_referer
      redirect_to(request.referer || '/') # HTTP_REFERER or '/'
    end
    
    def current_lead
      @current_lead ||= cookies[:campaign_lead_key] && Lead.find_by_key(cookies[:campaign_lead_key])
    end
    helper_method :current_lead
    
   
    
    def capture_coupon
      session[:coupon_code] = params[:coupon_code] if params[:coupon_code]
    end
end
