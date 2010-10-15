class ProductsController < ApplicationController
  before_filter :find_store
  before_filter :find_category
  before_filter :find_cart
  
  def index
    @products = @store.products.in_category(@category).paginate(:page => params[:page], :per_page => App.per_page[:products])
  end
  
  def show
    @product = @store.products.in_category(@category).find_by_url!(params[:id])
  end
  
  protected
    
    def find_store
      @store = Store.find_by_url!(params[:store_id])
    end
    
    def find_category
      @category = ProductCategory.find_by_url!(params[:category_id])
    end
  
end
