module GroupsHelper
  
  def group_membership_controls_for(group_membership)
    controls = ""
    
    controls << button_to('Remove Member', group_membership_path(group_membership), :method => :delete, :class => 'remove-group-member-button small', :id => "remove_group_member_#{dom_id(group_membership)}") if group_membership.active? && group_membership.user != group_membership.group.owner
    controls << button_to('Accept Membership', group_membership_path(group_membership, :decision => :activate), :method => :put, :class => 'accept-group-membership-button button green medium', :id => "accept_group_membership_#{dom_id(group_membership)}") if group_membership.pending?
    controls << button_to('Deny Membership', group_membership_path(group_membership, :decision => :deny), :method => :put, :class => 'deny-group-membership-button button red medium', :id => "deny_group_membership_#{dom_id(group_membership)}") if group_membership.pending?
    controls << content_tag(:div, nil, :class => 'clear-right')

    content_tag(:div, controls, :class => 'group-membership-controls')
  end
  
  def join_or_leave_group_button(group)
    if current_user.member_of?(group)
      button_to('Leave Group', group_membership_path(current_user.membership_for(group)), :method => :delete, :class => 'leave-group-button small right')
    else 
      button_to('Join Group', group_memberships_path(:group => group.to_param), :class => 'join-group-button button green bigrounded right')
    end
  end
end