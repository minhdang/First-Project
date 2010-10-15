class Admin::CampaignsController < Admin::AdminController
  
  before_filter :find_campaign, :only => [:show, :edit, :update, :destroy]
  
  def index
    @campaigns = Campaign.paginate(:page => params[:page], :per_page => App.admin_per_page[:campaigns])
  end
  
  def show
    @leads = @campaign.leads.paginate(:page => params[:page], :per_page => 100)
  end
  
  def new
    @campaign = Campaign.new
  end
  
  def edit
  end
  
  def create
    @campaign = Campaign.new(params[:campaign])
    
    if @campaign.save
      flash[:notice] = 'The campaign was successfully created'
      redirect_to admin_campaign_path(@campaign)
    else
      render :new
    end
  end
  
  def update
    if @campaign.update_attributes(params[:campaign])
      flash[:notice] = 'The campaign was successfully updated'
      redirect_to admin_campaign_path(@campaign)
    else
      render :edit
    end
  end
  
  def destroy
    @campaign.destroy
    flash[:notice] = 'The campaign was destroyed'
    redirect_to admin_campaigns_path
  end
  
  protected
  
    def find_campaign
      @campaign = Campaign.find_by_key!(params[:id])
    end
  
end
