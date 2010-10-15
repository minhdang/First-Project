class User
  has_one :inventors_digest_subscription, :dependent => :destroy
  
  def start_id_subscription!
    if membership && !membership.free? && membership.payment.billing_address.country == 'US'
      create_inventors_digest_subscription(:mailing_address => membership.payment.billing_address.clone)
    end
  end
  
  def cancel_id_subscription!
    inventors_digest_subscription.destroy if inventors_digest_subscription
  end
end