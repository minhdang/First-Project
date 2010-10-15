class Admin::Lounge::AnnouncementsController < Admin::AdminController
  
  role_required [:superuser, :lps_admin], :index, :show, :new, :edit, :create, :update, :destroy
  
  def index
    @announcements = Announcement.find(:all)
  end
  
  def show
    @announcement = Announcement.find(params[:id])
  end
  
  def new
    @announcement = Announcement.new
  end
  
  def create
    announcement = Announcement.new(params[:announcement])
    if current_user.announcements << announcement
      flash[:notice] = 'Insider Announcement was saved'
      redirect_to admin_lounge_announcements_url
    else
      flash[:error] = 'There was a problem saving your announcements'
      render :action => :new
    end
  end
  
  def edit
    @announcement = Announcement.find(params[:id])
  end
  
  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(params[:announcement])
      flash[:notice] = 'successfully updated'
      redirect_to admin_lounge_announcements_url
    else
      flash[:error] = 'There was problem updating your announcement'
      render :action => :edit
    end
  end
  
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    redirect_to admin_lounge_announcements_url
  end
  
end
