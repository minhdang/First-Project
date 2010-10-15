class Admin::SponsorsController < Admin::AdminController
  role_required [:lps_judge, :lps_commentator], :index, :show
  role_required [:superuser, :lps_admin], :index, :show, :new, :edit, :create, :update, :destroy
  
  before_filter :find_sponsor, :only => [:edit, :update, :destroy]
  
  def index
    @sponsors = Sponsor.all
  end
  
  def new
    @sponsor = Sponsor.new
  end
  
  def edit
  end
  
  def create
    @sponsor = Sponsor.new(params[:sponsor])
    
    if @sponsor.save
      flash[:notice] = "'#{@sponsor.name}' was successfully added as a sponsor."
      redirect_to admin_sponsors_path
    else
      render :new, :status => :bad_request
    end
  end
  
  def update
    if @sponsor.update_attributes(params[:sponsor])
      flash[:notice] = "The sponsor was successfully updated."
      redirect_to admin_sponsors_path
    else
      render :edit, :status => :bad_request
    end
  end
  
  def destroy
    @sponsor.destroy
    flash[:notice] = "The sponsor was successfully destroyed."
    redirect_to admin_sponsors_path
  end
  
  protected
    def find_sponsor
      @sponsor = Sponsor.find_by_initials!(params[:id])
    end
  
end
