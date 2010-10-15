class InsidersController < ApplicationController
  layout 'seventy-five-percent'
 
  before_filter :find_user, :except => [:video,:episode]
  
  
  def show
  end
  
  def insider
  end
  
  def public
  end
  
  def video
    respond_to do |format|
      format.js {
        @episode = TmpEpisode.find_by_episode(params[:id])
        render :layout => false
      }
    end
  end
  
  def episode
    respond_to do |format|
      format.js {
        @episode = TmpEpisode.find_by_episode(params[:id])
        render :layout => false
      }
    end
  end
  
  protected
  
  def find_user
    if logged_in?
      @user = current_user
      set_view(@user)
    else
      render :action => 'public'
    end
  end
  
  def set_view(user)
     if @user.member
       insider_setup
       render :action => 'insider', :layout => 'layouts/insider'
     else
       render :action => 'show'
     end
  end
  
  def insider_setup
    @announcements = Announcement.current
    event          = Event.current
    @event         = event.first
    @episodes      = TmpEpisode.all
  end
  
end
