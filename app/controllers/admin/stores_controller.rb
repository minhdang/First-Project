class Admin::StoresController < Admin::AdminController
  
  role_required :fulfillment_provider, :index, :show
  role_required [:superuser, :store_admin], :index, :show, :new, :edit, :create, :update, :destroy
  before_filter :find_store, :only => [:edit, :update, :destroy]
  
  def index
    @stores = Store.paginate(:page => params[:page], :per_page => App.admin_per_page[:stores])
  end
  
  def new
    @store = Store.new
  end
  
  def edit
  end
  
  def create
    @store = Store.new(params[:store])
    if @store.save
      flash[:notice] = "Store created successfully"
      redirect_to admin_store_products_path(@store)
    else
      render :action => :new
    end
  end
  
  def update
    if @store.update_attributes(params[:store])
      flash[:notice] = "Store updated successfully"
      redirect_to admin_store_products_path(@store)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @store.destroy
      flash[:notice] = "'#{h @store.name}' was deleted successfully"
    else
      flash[:error] = "Error deleting store. Please try again."
    end
    redirect_to admin_stores_path
  end
  
  protected
    
    def find_store
      @store = Store.find_by_url!(params[:id])
    end
  
end
