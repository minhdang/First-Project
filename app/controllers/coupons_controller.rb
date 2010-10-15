class CouponsController < ApplicationController
  
  def show
    # For now, we only want users coming from campaigns
    # who have not signed up yet to get this offer
    redirect_to(root_path) unless current_lead && !logged_in?
    
    @coupon = Coupon.find_by_url!(params[:id])
  end
  
end
