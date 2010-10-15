class OrdersController < ApplicationController
  ssl_required :new, :edit, :create, :update
  
  before_filter :login_required
  before_filter :find_store
  before_filter :find_order, :except => [:new, :create]
  before_filter :find_cart, :only => [:new, :create, :update]
  before_filter :update_ship_to_region, :only => [:create, :update], :if => :ship_to_region_supplied?
  before_filter :build_order_from_cart, :only => [:new, :create]
  
  def show
  end
  
  def new
    @order.build_payment
    @order.payment.build_billing_address
    @order.build_ship_to_address
  end
  
  def edit
  end
  
  def create
    if @order.update_attributes(params[:order]) # Update since we already built one from the cart session
      if @order.pay!
        @cart.empty! # Empty the cart now that the order has gone through
        redirect_to store_order_path(@store, @order)
      else
        render :action => :edit
      end
    else
      @order.build_payment if @order.payment.blank?
      @order.payment.build_billing_address if @order.payment.billing_address.blank?
      @order.build_ship_to_address if @order.ship_to_address.blank?
      render :action => :new
    end
  end
  
  def update
    if @order.update_attributes(params[:order]) && @order.pay!
      @cart.empty! # Empty the cart now that the order has gone through
      redirect_to store_order_path(@store, @order)
    else
      render :action => :edit
    end      
  end
  
  protected
    def find_store
      @store = Store.find_by_url!(params[:store_id])
    end
    
    def find_order
      @order = current_user.orders.find_by_number!(params[:id])
    end
    
    def build_order_from_cart
      @order = Order.build_from_cart(@cart, :user => current_user, :store => @store)
    end
    
    def ship_to_region_supplied?
      (params[:order][:ship_to_address_attributes] &&!params[:order][:ship_to_address_attributes][:state].blank?) || 
        (params[:order][:payment_attributes][:billing_address_attributes] && !params[:order][:payment_attributes][:billing_address_attributes][:state].blank?)
    end
    
    def update_ship_to_region
      region =  params[:order][:ship_to_address_attributes][:state].blank? ? 
                params[:order][:payment_attributes][:billing_address_attributes][:state] :
                params[:order][:ship_to_address_attributes][:state]
      session[:ship_to_region] = region
    end
end
