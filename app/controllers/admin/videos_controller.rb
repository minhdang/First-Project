class Admin::VideosController < Admin::AdminController
  before_filter :find_video_category, :only => [:new, :index, :show]
  before_filter :find_videos, :only => [:index]
  before_filter :find_video, :only => [:edit, :update, :show, :destroy]
  
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
  end

  def new
    @video = Video.new
  end
  
  def create
   @video = Video.new(params[:video]) 

   if @video.save
     flash[:notice] = 'The video created successfully'
     redirect_to admin_video_category_videos_path(@video.video_category)
   else
     render :action => 'new'
   end
  end
  
  def edit
  end
  
  def update
    if @video.update_attributes(params[:video])
      flash[:notice] = "The video updated successfully"
      redirect_to admin_video_category_videos_path(@video.video_category)
    else
      render :action => 'edit'
    end
  end
  
  def show
  end
  
  def destroy
    @video.destroy
    flash[:notice] = "The video destroyed successfully"
    redirect_to admin_video_category_videos_path(@video.video_category)
  end
  
  protected
    
    def find_video_category
      @video_category = VideoCategory.find_by_url!(params[:video_category_id]) if params[:video_category_id]
    end
  
    def find_videos
      @videos = @video_category.nil? ? Video.all : @video_category.videos
    end
    
    def find_video
      @video = Video.find(params[:id])
    end
end