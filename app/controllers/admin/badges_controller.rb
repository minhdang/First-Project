class Admin::BadgesController < Admin::AdminController
  
  def index
    @badges = Badge.all
  end
  
  def new
    @badge = Badge.new
  end
  
  def create
    @badge = Badge.new(params[:badge])
    
    if @badge.save
      flash[:notice] = 'Woot! The badge was created successfully'
      redirect_to admin_badges_path
    else
      render :action => :new
    end
  end
end
