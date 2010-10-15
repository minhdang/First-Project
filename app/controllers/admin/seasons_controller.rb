class Admin::SeasonsController < Admin::AdminController
  before_filter :find_season, :only => [:edit, :update, :show]
  
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @seasons = Season.find(:all)
  end
  
  def new
    @season = Season.new
  end
  
  def create
    @season = Season.new(params[:season])
    if @season.save
      flash[:notice] = "The season created successfully"
      redirect_to admin_seasons_path
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @season.update_attributes(params[:season])
      flash[:notice] = 'The season updated successfully'
      redirect_to admin_seasons_path
    else
      render :action => :edit
    end
  end
  
  def show  
  end
  
  protected
    def find_season
      @season = Season.find_by_url!(params[:id])
    end
end
