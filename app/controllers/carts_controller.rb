class CartsController < ApplicationController
  before_filter :find_store
  before_filter :find_cart
  before_filter :find_product, :except => [:show, :update]
  before_filter :find_product_type, :except => [:show, :update]
  
  def show
  end
  
  # Update cart quantities
  def update
    params[:product_type_quantities].each do |product_type_id, quantity|
      product_type = ProductType.find(product_type_id)
      @cart.update_product_quantity(product_type, quantity)
    end
    
    # Update the ship to region on the cart to calculate tax
    session[:ship_to_region] = params[:ship_to_region] if params[:ship_to_region]
    
    # Apply a coupon code if one was provided
    unless params[:coupon_code].blank?
      if @store.coupons.valid.exists?(:code => params[:coupon_code])
        session[:coupon_code] = params[:coupon_code]
        flash[:notice] = "The coupon '#{@cart.coupon.code} - #{@cart.coupon.description}' was added to your cart."
      else
        flash[:notice] = "The coupon '#{params[:coupon_code]}' does not exist or is no longer valid."
      end
    end
    # Remove the coupon if deleted
    session[:coupon_code] = nil if params[:commit] == 'Remove Coupon'
    
    if params[:commit] == 'Checkout'
      redirect_to new_store_order_path(@store)
    else
      flash[:notice] ||= 'Your cart was successfully updated'
      redirect_to store_cart_path(@store)
    end
  end
  
  def add_product
    if @product_type && @cart.add_product(@product_type)
      return_to = request.env['HTTP_REFERER']
      flash[:notice] = "1 '#{h @product.name}' was added to your cart. <a href='#{return_to}'>Click here to continue shopping</a>."
    end
    
    redirect_to store_cart_path(@store)
  end
  
  def remove_product
    if @product_type && @cart.remove_product(@product_type)
      flash[:notice] = "1 '#{h @product.name}' was removed from your cart"
    end
    
    redirect_to store_cart_path(@store)
  end
  
  protected
  
    def find_store
      @store = Store.find_by_url!(params[:store_id])
    end
    
    def find_product
      @product = @store.products.find(params[:product_id])
    end
  
    def find_product_type
      @product_type = @product.types.find(params[:product_type_id])
    end
end
