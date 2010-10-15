class UserBlogEntriesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_user
  before_filter :handle_user, :only => [:index, :show]
  before_filter :find_blog_entry, :only => [:show, :edit, :update, :destroy]
  before_filter :owner_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :viewable_by_current_user_check, :only => [:index, :show]

  def index
    @blog_entries = @user.blog_entries.paginate(:per_page => App.per_page[:user_blog_entries], :page => params[:page])
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @blog_entry.update_attributes(params[:blog_entry])
      flash[:notice] = "Your blog entry was updated successfully."
      redirect_to user_blog_entry_path(@user, @blog_entry)
    else
      render :action => :edit
    end
  end
  
  def new
    @blog_entry = @user.blog_entries.new
  end
  
  def create
    @blog_entry = @user.blog_entries.new(params[:blog_entry])
    if @blog_entry.save
      flash[:notice] = "Your blog entry was created successfully."
      redirect_to user_blog_entries_path(@user)
    else
      render :action => :new
    end
  end
  
  def destroy
    if @blog_entry.destroy
      flash[:notice] = "Your blog entry was successfully deleted."
    else
      flash[:error] = "Your blog entry could not be deleted."
    end
    redirect_to user_blog_entries_path(@user)
  end
  
  private
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def find_blog_entry
      @blog_entry = @user.blog_entries.find_by_url!(params[:id])
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
      viewable = @user.blog_viewable_by?(current_user)
      unless viewable
        flash[:error] = "You are not authorized to view blog posts added by #{@user.login}."
        redirect_to user_path(@user)
      end
      return viewable
    end
end