class VideosController < ApplicationController
  before_filter :find_video_category, :only => [:show]
  before_filter :find_video, :only => [:show]
  before_filter :ensure_logged_in_if_video_is_not_free, :only => [:show]
  before_filter :ensure_member_if_video_is_not_free, :only => [:show]
  
  def index
    @seasons = Season.find(:all, :order => 'season_number DESC')
    @video_categories = VideoCategory.find(:all)
    render :template => 'videos/hulu'
  end

  def show
  end
  
  def hulu
    @video_categories = VideoCategory.find(:all)
  end

  protected
    def find_video_category
      @video_category = VideoCategory.find_by_url!(params[:video_category_id]) if params[:video_category_id]
    end
  
    def find_video
      @video = Video.find(params[:id])
    end
    
    def ensure_logged_in_if_video_is_not_free
      logged_in_or_free = logged_in? || @video.free?
      unless logged_in_or_free
        flash[:notice] = "You must be logged in to view this video."
        login_required
      end
      logged_in_or_free
    end
    
    def ensure_member_if_video_is_not_free
      member_or_free = (current_user && current_user.member?) || @video.free?
      unless member_or_free
        flash[:notice] = "This video is only available to Edison Insiders. " +
                         "Check out all the benefits Edison Insiders receive below."
        redirect_to lounge_path

      end
      member_or_free
    end
end
