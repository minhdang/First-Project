class Admin::VideoCategoriesController < Admin::AdminController
  before_filter :find_video_category, :only => [:show, :edit, :update, :destroy]
  
  def index
    @video_categories = VideoCategory.all
  end
  
  def show
  end

  def edit
  end
  
  def new
    @video_category = VideoCategory.new
  end
  
  def create
    @video_category = VideoCategory.new(params[:video_category])
    
    if @video_category.save
      flash[:success] = 'The video category created successfully'
      redirect_to admin_video_categories_path
    else
      render :new
    end
  end
  
  def update
    if @video_category.update_attributes(params[:video_category])
      flash[:success] = 'The video category updated successfully'
      redirect_to admin_video_categories_path
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @video_category.destroy
      flash[:success] = 'The video category destroyed successfully'
      redirect_to admin_video_categories_path
    else
      render :action => :new
    end
  end
  
  protected
    def find_video_category
      @video_category = VideoCategory.find_by_url!(params[:id])
    end
end
