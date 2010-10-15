class Admin::SiteBulletinsController < Admin::AdminController
  
  def index
    @site_bulletins = SiteBulletin.find(:all)
  end
  
  def new
    @site_bulletin = SiteBulletin.new
  end
  
  def create
    @site_bulletin = SiteBulletin.new(params[:site_bulletin])
    if @site_bulletin.save
      @site_bulletin.move_to_state(params[:site_bulletin][:state]) if params[:site_bulletin][:state]
      flash[:notice] = "Your bulletin has been saved"
      redirect_to admin_site_bulletins_path
    else
      flash[:notice] = 'There was an error creating your bulletin'
      render :action => 'new'
    end
  end
  
  def show
    @site_bulletin = SiteBulletin.find(params[:id])
  end
  
  def edit
    @site_bulletin = SiteBulletin.find(params[:id])
  end
  
  def update
    @site_bulletin = SiteBulletin.find(params[:id])
    @site_bulletin.move_to_state(params[:site_bulletin][:state]) if params[:site_bulletin][:state]
    if @site_bulletin.update_attributes(params[:site_bulletin])
      flash[:notice] = 'Your bulletin has been updated'
      redirect_to admin_site_bulletins_path
    else
      flash[:error] = 'There was an issues saving your bulletin'
      render :action => 'edit'
    end
  end
  
  def destroy
    @site_bulletin = SiteBulletin.find(params[:id])
    @site_bulletin.destroy
    redirect_to admin_site_bulletins_path
  end


end
