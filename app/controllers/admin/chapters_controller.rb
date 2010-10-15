class Admin::ChaptersController < Admin::AdminController
  before_filter :find_chapter, :only => [:edit, :update, :show, :destroy]
  
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @episode = Episode.find(params[:episode_id])
  end

  def new
    @chapter = Chapter.new
  end
  
  def create
    @chapter = Chapter.new(params[:chapter])
    
    if @chapter.save!
      flash[:notice] = "The chapter created successfully"
      redirect_to admin_episode_path(params[:episode_id])
    else
      render :action => :new
    end
  end

  def edit
  end
  
  def update    
    if @chapter.update_attributes(params[:chapter])
      flash[:notice] = "The chapter updated successfully"
      redirect_to admin_episodes_path
    else
      render :action => :edit
    end
  end

  def show
  end

  def destroy
    @chapter.destroy
    flash[:success] = 'The chapter destroyed successfully'
    redirect_to admin_episodes_path
  end
  
  protected
    def find_chapter
      @chapter = Chapter.find_by_chapter_number!(params[:id])
    end
end