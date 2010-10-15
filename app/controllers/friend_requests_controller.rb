class FriendRequestsController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :handle_user
  before_filter :owner_required
  
  def index
    @friend_requests = @user.friend_requests
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
  
    def owner_required
      owner = current_user == @user
      unless owner
        flash[:error] = "You are not authorized to view this page."
        redirect_to login_path
      end
    end
end