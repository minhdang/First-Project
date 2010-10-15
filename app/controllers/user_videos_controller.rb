class UserVideosController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :handle_user, :only => [:index, :show]
  before_filter :find_video, :only => [:edit, :update, :destroy, :show]
  before_filter :owner_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :viewable_by_current_user_check, :only => [:index, :show]
    
  def index
    @user_videos = @user.user_videos.find(:all, :order => 'created_at DESC')
  end
  
  def show
  end

  def new
    @user_video = @user.user_videos.new
  end
  
  def create
    @user_video = @user.user_videos.new(params[:user_video])
    if @user_video.save
      flash[:notice] = "The video created successfully"
      redirect_to edit_user_video_path(@user, @user_video)
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @user_video.update_attributes(params[:user_video])
      flash[:notice] = "The video updated successfully"
      redirect_to user_videos_path(@user)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @user_video.destroy
      flash[:notice] = "The video destroyed successfully"
    else
      flash[:notice] = "The video could not be destroyed"
    end

    redirect_to user_videos_path(@user)
  end
  
  private
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def find_video
      @user_video = @user.user_videos.find(params[:id])
    end
    
    def owner_required
      is_owner = (current_user && current_user == @user)
      unless is_owner
        flash[:error] = 'You are not authorized to view this page.'
        redirect_to login_path
      end
      is_owner
    end
  
    def viewable_by_current_user_check
      viewable = @user.videos_viewable_by?(current_user)
      unless viewable
        flash[:error] = "You are not authorized to view videos uploaded by #{@user.login}."
        redirect_to user_path(@user)
      end
      return viewable
    end
end