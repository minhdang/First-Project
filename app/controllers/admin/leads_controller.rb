class Admin::LeadsController < Admin::AdminController
  
  def show
    @campaign = Campaign.find_by_key!(params[:campaign_id])
    @lead     = @campaign.leads.find_by_key!(params[:id])
  end
  
end