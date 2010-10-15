class Admin::BannersController < Admin::AdminController
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @banners = Banner.find(:all)
  end
  
  def new
    @banner = Banner.new
  end
  
  def create
    @banner = Banner.new(params[:banner])
    if @banner.save
      flash[:notice] = "The banner was created and is now being displayed"
      redirect_to admin_banners_path
    else
      render :new
    end
  end
  
  def edit
    @banner = Banner.find(params[:id])
  end
  
  def update
    @banner = Banner.find(params[:id])
    if @banner.update_attributes(params[:banner])
      flash[:notice] = "The banner was edited successfully"
      redirect_to admin_banners_path
    else
      render :edit
    end
  end
  
  def show
    @banner = Banner.find(params[:id])
  end
  
  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    flash[:notice] = "The banner was destroyed successfully"
    redirect_to admin_banners_path
  end
end
