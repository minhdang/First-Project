class ChaptersController < ApplicationController
  before_filter :find_season, :only => [:show, :index]
  before_filter :find_episode, :only => [:show, :index]
  before_filter :ensure_logged_in_if_episode_is_not_free, :only => [:show, :index]
  before_filter :ensure_member_if_episode_is_not_free, :only => [:show, :index]
  
  def index
    redirect_to season_episode_chapter_path(@season, @episode, @episode.first_chapter)
  end

  def show
    @chapter = @episode.chapters.find_by_chapter_number!(params[:id])
  end
  
  protected
    
    def find_season
      @season = Season.find_by_url!(params[:season_id])
    end

    def find_episode
      @episode = @season.episodes.find(params[:episode_id])
    end

    def ensure_logged_in_if_episode_is_not_free
      logged_in_or_free = current_user || @episode.free?
      unless logged_in_or_free
        flash[:notice] = "You must be logged in to view this episode."
        login_required
      end
      
      logged_in_or_free
    end
    
    def ensure_member_if_episode_is_not_free
      member_or_free = (current_user && current_user.member?) || @episode.free?
      unless member_or_free
        flash[:notice] = "This video is only available Edison Insiders. " +
                         "Check out all the benefits Edison Insiders receive below."
        redirect_to membership_path
      end
      member_or_free
    end
end
