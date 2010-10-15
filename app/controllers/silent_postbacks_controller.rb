class SilentPostbacksController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  # POST /silent_postbacks
  def create
    s = GatewayStatus.init_status(params)
    s.save
    s.handle
    render :nothing=>true
  end
  
end