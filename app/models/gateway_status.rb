class GatewayStatus < ActiveRecord::Base
    
  # -------------------------------------------------
  # Relationships
  # -------------------------------------------------

  belongs_to :user
  
  
  # -------------------------------------------------
  # Static Variables
  # -------------------------------------------------
  
  REDEEMABLE = [ActiveMerchant::Billing::AuthorizeNetGateway::DECLINED, ActiveMerchant::Billing::AuthorizeNetGateway::ERROR]
  
  
  # -------------------------------------------------
  # Static Methods
  # -------------------------------------------------
  
  def self.init_status(params)
    response_code = params[:x_response_code].to_i
    
    GatewayStatus.new(
                      :response_code=>response_code, 
                      :user_id =>params[:x_cust_id],
                      :redeemed => (REDEEMABLE.include?(response_code) and params[:x_subscription_id]) ? false : nil,
                      :downgraded => (REDEEMABLE.include?(response_code) and params[:x_subscription_id]) ? false : nil,
                      :subscription_id => params[:x_subscription_id],
                      :trans_id => params[:x_trans_id],
                      :other=>params.inspect() )
  end
  
  def self.redeemable_status(user)
    find(:first, :conditions=>["user_id=? AND redeemed=0 AND subscription_id=? AND response_code IN (?)", user.id, user.subscription_id, REDEEMABLE])
  end
  
  def self.failures
    find(:all, :conditions=>["user_id IS NOT NULL AND redeemed=0 AND downgraded=0 AND subscription_id IS NOT NULL AND response_code IN (?) AND created_at < ?", REDEEMABLE, (Date.today - 5)] )
  end
  
  # -------------------------------------------------
  # Public Methods
  # -------------------------------------------------
  
  def redeem(transaction_id)
    self.redeemed_trans_id = transaction_id
    self.redeemed = true
    save!
  end
  
  def redeemable?
    REDEEMABLE.include?(self.response_code)
  end
  
  def downgrade
    self.user.downgrade
    update_attribute(:downgraded, true)
  end
  def revert_downgrade
    self.user.revert_downgrade
    update_attribute(:downgraded, false)
  end
  
  def handle
    concrete_status.handle
  end
  
  def params
    eval(self.other)
  end
  
  
  private
  
  # -------------------------------------------------
  # Private Methods
  # -------------------------------------------------
  
  def concrete_status
    case self.response_code
      when ActiveMerchant::Billing::AuthorizeNetGateway::APPROVED then return ApprovedStatus.new(self)
      when ActiveMerchant::Billing::AuthorizeNetGateway::DECLINED then return DeclinedStatus.new(self)
      when ActiveMerchant::Billing::AuthorizeNetGateway::ERROR then return ErrorStatus.new(self)
      when ActiveMerchant::Billing::AuthorizeNetGateway::FRAUD_REVIEW then return FraudReviewStatus.new(self)
    end
  end
  
end


# ---------------------------------------------------
# Classes implementing the Gof "State" pattern
# ---------------------------------------------------
 
class AbstractGatewayStatus
  def initialize(gateway_status)
    @gateway_status = gateway_status
  end
  def gateway_status
    @gateway_status
  end
  
  # The membership related to this gateway status if this is an arb entry
  def membership
    gateway_status.subscription_id ? Membership.find(:first, :conditions => {:subscription_id => gateway_status.subscription_id}, :order => 'id DESC') : nil
  end
end


class ApprovedStatus < AbstractGatewayStatus
  def handle
    membership.activate! unless membership.nil? || membership.active?
  end
end

class DeclinedStatus < AbstractGatewayStatus
  def handle
    membership.past_due! if membership 
  end
end

class ErrorStatus < AbstractGatewayStatus
  def handle
    membership.past_due! if membership
  end
end

class FraudReviewStatus < AbstractGatewayStatus
  def handle
    membership.past_due! if membership
  end
end