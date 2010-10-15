class GroupMembershipObserver < ActiveRecord::Observer
  
  # Send an email to the group owner to activate this membership
  # if the membership is not active. ie. this is a private group
  def after_create(group_membership)
    GroupMailer.deliver_group_owner_pending_membership_notification(group_membership) if group_membership.pending?
  end
  
  def after_save(group_membership)
    # Create a notice that the user joined the group.
    group_membership.user.send_later(:notice!,group_membership,true) if group_membership.recently_activated? && !Notice.already_noticed?(group_membership)
  end
  
end