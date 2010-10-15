class Coupon < ActiveRecord::Base
  
  DiscountTypes = ['%','$','FREE','FREE SHIPPING']
  
  acts_as_url :code
  
  belongs_to :discountable, :polymorphic => true
  
  validates_presence_of     :code, :description, :discount_type, :discount
  validates_format_of       :code, :with => /^[^\s]*$/
  validates_uniqueness_of   :code, :case_sensitive => false
  validates_numericality_of :discount
  
  named_scope :valid, lambda {
    {
      :conditions =>  [
                        "(expires_at IS NULL AND max_redemptions IS NULL) OR " \
                        "(expires_at IS NULL AND max_redemptions IS NOT NULL AND redemptions < max_redemptions) OR " \
                        "(max_redemptions IS NULL AND expires_at IS NOT NULL AND expires_at > ?) OR " \
                        "(expires_at IS NOT NULL AND max_redemptions IS NOT NULL AND (" \
                          "expires_at > ? AND redemptions < max_redemptions" \
                        "))",
                        Time.now, Time.now
                      ]
    }
  }
  
  def to_param
    url
  end
  
  # See if this coupon is applicable to a
  # a particular discountable_type
  def applicable?(item, user = nil)
    return false if members_only? && (user.nil? || !user.member?)
    return false if new_users_only? && ((user.activated_at + App.new_user_period.days) < Time.zone.now)
    #return false if user && user.coupons.include?(self) 
    
    case discountable_type
    when 'Store'
      discountable == item.store
    when 'Product'
      discountable == item.product
    when 'ProductType'
      discountable == item
    when 'Submission'
      item.instance_of?(Submission)
    end
  end
  
  # Calculates the reduced value of a given price
  # based on this coupons credentials
  def applied_price(price_before)
    case discount_type
    when 'FREE'
      0.00
    when '%'
      percentage = discount / 100
      price_before - (price_before * percentage)
    when '$'
      price_before - discount
    else
      price_before
    end
  end
  
  def free_shipping?
    discount_type == 'FREE SHIPPING'
  end
  
  def redeem!
    increment!(:redemptions)
  end
  
end
