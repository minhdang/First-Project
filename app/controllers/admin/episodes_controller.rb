class Admin::EpisodesController < Admin::AdminController

  before_filter :find_season, :only => [:new, :edit, :update, :show]
  before_filter :find_episode,       :only => [:edit, :update, :show, :destroy]
  
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @episodes = Episode.all
  end

  def show
  end
  
  def edit
  end
  
  def new
    @episode = Episode.new
  end

  def create
    @episode = Episode.new(params[:episode])
    if @episode.save
      flash[:notice] = "The episode created successfully"
      redirect_to admin_episodes_path
    else
      render :action => :new
    end
  end
    
  def update
    if @episode.update_attributes(params[:episode])
      flash[:notice] = "The episode updated successfully"
      redirect_to admin_episodes_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    @episode.destroy
    flash[:notice] = "The episode destroyed successfully"
    redirect_to admin_episodes_path
  end

  protected
    def find_season
      @season = Season.find_by_url!(params[:season_id]) if params[:season_id]
    end
    
    def find_episode
      @episode = @season.nil? ? Episode.find(params[:id]) : @season.episodes.find(params[:id])
    end
end
