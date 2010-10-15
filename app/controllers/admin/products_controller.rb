class Admin::ProductsController < Admin::AdminController
  
  role_required [:superuser, :store_admin], :new, :edit, :create, :update, :destroy
  
  before_filter :find_store
  before_filter :find_product, :except => [:index, :new, :create]
  
  def index
    @products = @store.products.paginate(:page => params[:page], :per_page => App.admin_per_page[:products])
  end
  
  def show
  end
  
  def new
    @product = Product.new
  end
  
  def edit
  end
  
  def create
    @product = @store.products.build(params[:product])
    
    if @product.save
      flash[:notice] = 'Product created successfully'
      redirect_to admin_store_product_path(@store, @product)
    else
      render :action => :new
    end
  end
  
  def update
    if @product.update_attributes(params[:product])
      flash[:notice] = "#{h @product.name} was updated successfully"
      redirect_to admin_store_product_path(@store, @product)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @product.destroy
      flash[:notice] = "'#{h @product.name}' was successfully deleted"
    else
      flash[:error] = "There was an error deleting the product. Please try again."
    end
    redirect_to admin_store_products_path(@store)
  end
    
  
  protected
  
    def find_store
      @store = Store.find_by_url!(params[:store_id])
    end
    
    def find_product
      @product = @store.products.find_by_url!(params[:id])
    end
end
