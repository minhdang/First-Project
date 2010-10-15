class CampaignsController < ApplicationController
  require 'uri'
  
  skip_before_filter :hijack_request
  
  layout 'plain'
  
  def show
    @campaign = Campaign.find_by_key!(params[:id])
    @lead     = @campaign.track_lead(request)
    cookies[:campaign_lead_key] = {:value => @lead.key, :expires => 1.month.from_now} if @lead
    
    if logged_in? && @lead
      @lead.user = current_user
      @lead.save
    end
    
    redirect_to @campaign.target, :status => :moved_permanently
  end
  
  # signup page shown after hijacking a user's request
  def signup
    @continue_to = URI.unescape(params[:continue_to].to_s)
  end
  
end