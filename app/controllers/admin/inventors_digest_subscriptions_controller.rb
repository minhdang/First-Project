class Admin::InventorsDigestSubscriptionsController < Admin::AdminController
  
  def index
    respond_to do |format|
      
      format.html { @subscriptions = InventorsDigestSubscription.paginate(:all, :page => params[:page], :per_page => App.admin_per_page[:users]) }
      format.csv
      
    end
  end
  
end