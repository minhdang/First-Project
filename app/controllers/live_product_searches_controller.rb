class LiveProductSearchesController < ApplicationController
  
  before_filter :capture_coupon
  
  def show
    @lps = LPS.find_by_key!(params[:id])
  end
  
  def landing_page
    @lps = LPS.find_by_landing_page_url!(params[:path], :order => 'id DESC')
    redirect_to live_product_search_path(@lps)
  end
  

  def insider_search_modal 
    respond_to do |format|
      format.js 
    end
  end

  def api
    @lps = LPS.current
    respond_to do |format|
      format.xml
    end
  end
    
end
