class GroupMailer < ApplicationMailer
  # Notify a group owner when there is a
  # pending membership for them to review
  def group_owner_pending_membership_notification(group_membership)
    setup_email(group_membership.group.owner)
    subject       "Edison Nation - #{group_membership.user.name} (#{group_membership.user.login}) wishes to join the `#{group_membership.group.title}` group"
    body          :owner => group_membership.group.owner, :user => group_membership.user, :group => group_membership.group
  end
end