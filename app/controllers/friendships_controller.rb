class FriendshipsController < ApplicationController
  before_filter :login_required
  before_filter :find_user, :only => :create
  before_filter :ensure_no_friendship, :only => :create
  
  def create
    if current_user.friendships.create(:friend => @user)
      flash[:notice] = "A friend request has been sent to #{@user.login} for approval."
    else
      flash[:error] = 'There was a problem creating the friend request. Please try again'
    end
    redirect_to user_friends_path(current_user)
  end
  
  def update
    friend_request = current_user.friend_requests.find(params[:id])
    
    case params[:decision].to_sym
    when :accept
      friend_request.accept!
      flash[:notice] = "#{friend_request.user.login} added to your friends list. The user will be notified through email."
    when :deny
      friend_request.deny!
    end
    redirect_to user_friends_path(current_user)
  end
  
  def destroy
    friendship = current_user.friendships.find(params[:id])
    if friendship.deny!
      flash[:notice] = "#{friendship.friend.login} has been removed from friends list"
    else
      flash[:error] = 'We were unable to remove this user from your friends list. Please try again'
    end
    redirect_to user_friends_path(current_user)
  end
  
  protected
  
    def find_user
      @user = User.find_by_login!(params[:friend])
    end
    
    def ensure_no_friendship
      friendship = current_user.friendship_with(@user)
      if friendship && !friendship.denied?
        flash[:notice] = "You are already friends with #{@user.login}. Please review your pending friend requests."
        redirect_to user_friends_path(current_user)
      end
      !friendship
    end
end
