class JavascriptsController < ApplicationController
  # This Controller generates dynamic Javascript files
  # So /javascripts/states_selector.js maps to this controller
  # if the file doesn't statically exist

  skip_before_filter :hijack_request
  skip_before_filter :verify_authenticity_token
  
  # We don't need to use a layout
  layout nil
  
  # Caching where able
  caches_action :states_selector
  
  # Used for dynamic country state selectors
  def states_selector
    respond_to do |format|
      format.js
    end
  end
  
  # Session specific JS
  def user_session
    @user = current_user
    
    if stale?(:last_modified => (@user && @user.updated_at.utc), :etag => @user)
      respond_to do |format|
        format.js
      end
    end
  end
  
  # Handle some user preferences on the client side so we can cache more
  def forum_preferences
    @preferences = user_preferences
    @topic_views = logged_in? ? current_user.topic_views : []
    respond_to do |format|
      format.js
    end
  end

  def preview_textile
    @html = RedCloth.new(params[:data]).to_html
  end
  
  protected
    # Serve SSL Versions of Files in SSL areas like checkout
    def ssl_allowed?
      true
    end
end
