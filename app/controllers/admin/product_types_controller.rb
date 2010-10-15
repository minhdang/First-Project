class Admin::ProductTypesController < Admin::AdminController
  
  role_required [:superuser, :store_admin], :new, :edit, :create, :update, :destroy
  
  before_filter :find_store
  before_filter :find_product
  before_filter :find_product_type, :except => [:new, :create]
  
  def new
    @product_type = @product.types.build
  end
  
  def edit
  end
  
  def create
    @product_type = @product.types.build(params[:product_type])
    @product_type.store = @store
    
    if @product_type.save
      flash[:notice] = 'Product type created successfully'
      redirect_to admin_store_product_path(@store, @product)
    else
      render :action => :new
    end
  end
  
  def update
    if @product_type.update_attributes(params[:product_type])
      flash[:notice] = "'#{h @product_type.name}' updated successfully"
      redirect_to admin_store_product_path(@store, @product)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @product_type.destroy
      flash[:notice] = "'#{h @product_type.name}' was successfully deleted"
    else
      flash[:error] = 'Error deleting product type. Please try again.'
    end
    redirect_to admin_store_product_path(@store, @product)
  end
  
  protected
  
    def find_store
      @store = Store.find_by_url!(params[:store_id])
    end
    
    def find_product
      @product = @store.products.find_by_url!(params[:product_id])
    end
    
    def find_product_type
      @product_type = @product.types.find_by_url!(params[:id])
    end
  
end
