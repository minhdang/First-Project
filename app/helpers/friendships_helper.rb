module FriendshipsHelper
  
  def friendship_controls_for(user)
    controls = ""
    if logged_in? && user != current_user
      if friendship = current_user.friendship_with(user)
        controls << button_to('Remove Friend', user_friendship_path(current_user, friendship), :method => :delete, :class => 'remove-friendship small', :id => "remove_#{dom_id(friendship)}", :confirm => 'Are you sure you would like to remove this user from your friends list.') if friendship.accepted?
        controls << button_to('Accept Friend Request', user_friendship_path(current_user, friendship, :decision => :accept), :method => :put, :class => 'accept-friendship button green medium', :id => "accept_#{dom_id(friendship)}") if current_user.received_friend_request?(friendship) && friendship.pending?
        controls << button_to('Ignore Friend Request', user_friendship_path(current_user, friendship, :decision => :deny), :method => :put, :class => 'deny-friendship button green medium', :id => "deny_#{dom_id(friendship)}") if current_user.received_friend_request?(friendship) &&friendship.pending?
      else
        controls << button_to('Add to Friends', user_friendships_path(current_user, :friend => user.to_param), :class => 'add-friend button green medium', :id => "add_#{dom_id(user)}", :confirm => 'Are you sure you would like to add this user to your friends list.')
      end
    end
    content_tag(:div, controls, :class => 'friendship-controls')
  end
end