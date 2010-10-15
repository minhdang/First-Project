class UserNeedsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]
  before_filter :find_user
  before_filter :handle_user, :only => [:index]
  before_filter :find_need, :only => [:edit, :update, :destroy]
  before_filter :ensure_need_owner, :only => [:edit, :update, :destroy]

  def index
    @needs = @user.needs.paginate(:per_page => App.per_page[:needs], :page => params[:page])
  end
  
  def edit
  end

  def update
    if @need.update_attributes(params[:need])
      flash[:notice] = "The need updated successfully"
      redirect_to user_needs_path(@user)
    else
      render :action => :edit
    end
  end
  
  def destroy
    @need.destroy
    flash[:notice] = "The need destroyed successfully"
    redirect_to user_needs_path(@user)
  end

  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def find_need
      @need = @user.needs.find_by_url!(params[:id])
    end
    
    def ensure_need_owner
      owner = current_user == @user
      unless owner
        flash[:error] = "You are not authorized to view this page."
        redirect_to login_path
      end
    end
end