class UserAlbumsController < ApplicationController
  before_filter :find_user
  before_filter :handle_user, :only => [:index, :show]
  before_filter :find_album, :only => [:edit, :update, :show, :destroy]
  before_filter :redirect_unless_owner, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :viewable_by_current_user_check, :only => [:index, :show]

  def index
    @albums = @user.user_albums
  end
  
  def new
    @album = @user.user_albums.new
  end
  
  def create
    @album = @user.user_albums.new(params[:user_album])
    if @album.save
      flash[:notice] = "The album was created successfully."
      redirect_to user_album_path(@user, @album)
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @album.update_attributes(params[:user_album])
      flash[:notice] = "The album was updated successfully."
      redirect_to user_albums_path(@user)
    else
      @album.url = @album.url_was if @album.url_changed?
      render :action => :edit
    end
  end
  
  def show
  end
  
  def destroy
    flash[:notice] = @album.destroy ? "Your album was successfully deleted." : "There was an error deleting your album."
    redirect_to user_albums_path(@user)
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def find_album
      @album = @user.user_albums.find_by_url!(params[:id])
    end
    
    def viewable_by_current_user_check
      viewable = @user.photos_viewable_by?(current_user)
      unless viewable
        flash[:error] = "You are not authorized to view photos added by #{@user.login}."
        redirect_to user_path(@user)
      end
      return viewable
    end
    
    def redirect_unless_owner
      owner = current_user == @user
      unless owner
        flash[:error] = "You are not authorized to view this page."
        redirect_to user_path(current_user)
      end
      return owner
    end
end