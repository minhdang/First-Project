class FriendshipObserver < ActiveRecord::Observer
  def after_create(friendship)
    FriendshipMailer.deliver_friend_request_sent(friendship) if friendship.pending?
    
    # Create a notice that the users are friends for the mirrored friendship
    friendship.user.send_later(:notice!,friendship,true) if friendship.accepted?
  end

  def after_save(friendship)
    
    # Send an email that the friendship has been accepted
    if friendship.user_id != 1 && friendship.recently_accepted?
      FriendshipMailer.deliver_friend_request_accepted(friendship)
    end
    
    # Create a notice that the users are now friends
    friendship.user.send_later(:notice!,friendship,true) if friendship.recently_accepted?
  end
end
