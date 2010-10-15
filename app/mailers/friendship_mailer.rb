class FriendshipMailer < ApplicationMailer
  def friend_request_sent(friendship)
    setup_email(friendship.friend)
    subject         "Edison Nation - You have a new friend request from #{friendship.user.login}"
    body            :friendship => friendship
  end
  
  def friend_request_accepted(friendship)
    setup_email(friendship.user)
    subject         "Edison Nation - #{friendship.friend.login} accepted your friend request"
    body            :friendship => friendship
  end
end
