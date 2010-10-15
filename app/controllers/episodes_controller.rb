class EpisodesController < ApplicationController
  before_filter :find_season, :only => [:show, :index]
  before_filter :find_episode, :only => :show
  before_filter :ensure_logged_in_if_episode_is_not_free, :only => :show
  before_filter :ensure_member_if_episode_is_not_free, :only => :show

  def index
    @episodes = @season.episodes.active
  end

  def show
    redirect_to season_episode_chapter_path(@season, @episode, @episode.first_chapter)
  end

  protected
  
    def find_season
      @season = Season.find_by_url!(params[:season_id])
    end
  
    def find_episode
      @episode = Episode.active.find(params[:id])
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
        flash[:notice] = "This video is only available to Edison Insiders. " +
                         "Check out all the benefits Edison Insiders receive below."
        redirect_to new_membership_path
      end
      member_or_free
    end
end
