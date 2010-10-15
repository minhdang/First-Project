class MembershipObserver < ActiveRecord::Observer
  
  def after_save(membership)
    
    if membership.recently_activated?
      
      # Add Gold member badge to the user
      gold_badge = Badge.find_by_id(1)
      membership.user.assign_badge!(gold_badge) if gold_badge
      
      # Start an Inventors Digest Subscription
      membership.user.start_id_subscription! unless membership.free?
      
      # Let the user know that their membership was activated
      UserMailer.deliver_membership_activation(membership.user)
      
      # Create a notice that the user has upgraded to a gold membership
      membership.user.send_later(:notice!,membership,true)
      
    elsif membership.recently_canceled?
      
      # Remove the Gold Member Badge
      gold_badge = Badge.find_by_id(1)
      membership.user.remove_badge!(gold_badge) if gold_badge
      
      # Cancel the User's Inventors Digest Subscription
      membership.user.cancel_id_subscription!
      
      # Let the user know that their membership was canceled
      UserMailer.deliver_membership_cancellation(membership.user)
      
    elsif membership.recently_past_due?
      
      # Deliver a notice to the user that their payment failed
      membership.reload
      UserMailer.deliver_update_membership_cc_alert(membership.user)
      
    end
    
  end
  
end
