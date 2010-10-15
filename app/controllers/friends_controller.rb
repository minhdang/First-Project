class FriendsController < ApplicationController
  before_filter :find_user
  before_filter :handle_user
  
  def index
    @friends = @user.friends.paginate(:page => params[:page], :per_page => App.per_page[:friendships])
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
end
