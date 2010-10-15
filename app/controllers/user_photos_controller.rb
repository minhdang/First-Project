class UserPhotosController < ApplicationController
  before_filter :find_user, :only => [:index, :new, :create, :show, :edit, :update, :destroy]
  before_filter :handle_user, :only => [:index, :show]
  before_filter :find_album, :only => [:new, :create, :show, :edit, :update, :destroy]
  before_filter :find_photo, :only => [:show, :edit, :update, :destroy]
  before_filter :viewable_by_current_user_check, :only => [:show]
  before_filter :owner_required, :only => [:new, :create, :edit, :update, :destroy]
  
  def index
  end
  
  def show
  end

  def edit
  end

  def new
    @photo = @album.user_photos.new
  end
  
  def create
    @photo = @album.user_photos.new(params[:user_photo])
    if @photo.save
      flash[:notice] = "Your photo was added successfully."
      redirect_to user_album_path(@user, @album)
    else
      render :action => :new
    end
  end
  
  def update
    if @photo.update_attributes(params[:user_photo])
      flash[:notice] = "Your photo was updated successfully."
      redirect_to user_album_path(@user, @album)
    else
      render :action => :edit
    end
  end
  
  def destroy
    @photo.destroy
    flash[:notice] = "Your photo was deleted successfully."
    redirect_to user_album_path(@user, @album)
  end

  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
  
    def find_album
      @album = @user.user_albums.find_by_url!(params[:album_id])
    end
  
    def find_photo
      @photo = @album.user_photos.find_by_url!(params[:id])
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
      viewable = @user.photos_viewable_by?(current_user)
      unless viewable
        flash[:error] = "You are not authorized to view photos added by #{@user.login}."
        redirect_to user_path(@user)
      end
      return viewable
    end
end