class Cart
  
  attr_reader :cart_items, :session, :user
  
  def self.base_class
    self
  end

  def id
    object_id
  end
  
  def initialize(store, session, user = nil)
    @store = store
    @session = session
    @session["store_#{@store.id}"] ||= {}
    @session["store_#{@store.id}"][:cart_items] ||= []
    @user = user
    
    # Initialize a list of cart items from the session
    @cart_items = {}
    @session["store_#{@store.id}"][:cart_items].each do |item|
      cart_item = Item.build_from_session(self, item)
      @cart_items[cart_item.product_type_id] = cart_item
    end
  end
  
  # Is the cart owner a member?
  def is_member?
    @user && @user.member?
  end
  
  def add_product(product_type)
    if @cart_items.has_key?(product_type.id)
      @cart_items[product_type.id].increment_quantity
    else
      @cart_items[product_type.id] = Item.new(self, product_type.id)
    end
    
    # Write the new cart state to the session
    save
    
    return @cart_items.has_key?(product_type.id)
  end
  
  def remove_product(product_type)
    if @cart_items.has_key?(product_type.id)
      @cart_items[product_type.id].decrement_quantity
    end
    
    # Write the new cart state to the session
    save
  end
  
  def update_product_quantity(product_type, quantity)
    if @cart_items.has_key?(product_type.id)
      @cart_items[product_type.id].quantity = quantity.to_i
    end
    
    # Write the new cart state to the session
    save
  end
  
  # The total amount of items in the cart counting for quantity
  def total_items
    total = 0
    @cart_items.each_value { |item| total += item.quantity }
    total
  end
  
  # An array of cart items
  def items
    @cart_items.values
  end
  
  def empty?
    items.empty?
  end
  
  # Remove all items from the cart
  def empty!
    @cart_items = {}
    save
  end
  
  # The subtotal of the cart items
  def subtotal
    @subtotal ||= items.inject(0.0) {|subtotal, item| subtotal += (item.final_price * item.quantity)}
  end
  
  # The total shipping of all the cart items
  def shipping
    @shipping ||= items.inject(0.0) {|shipping, item| shipping += (item.final_shipping * item.quantity)}
  end
  
  # The tax for the subtotal of all items in the cart
  def tax
    @tax ||= subtotal * tax_rate
  end
  
  # The grand total of the cart
  def total
    @total ||= subtotal + shipping + tax
  end
  
  # Write the current cart items to the session
  # if the quantity is > than 0
  def save
    @session["store_#{@store.id}"][:cart_items] = [] # Clear the session
    @cart_items.each_value do |cart_item|
      @session["store_#{@store.id}"][:cart_items] << cart_item.to_s unless cart_item.none?
    end
  end
  
  def coupon
    @session[:coupon_code] && Coupon.valid.find_by_code(@session[:coupon_code])
  end
  
  protected
  
    # The applicable tax rate
    def tax_rate
      (@session[:ship_to_region] && taxable_in?(@session[:ship_to_region])) ? TaxableArea.find_by_region(@session[:ship_to_region]).rate : 0.0
    end
  
    # Does this cart have any items that are subject to tax in a given region?
    def taxable_in?(ship_to)
      taxable = false
      items.each do |item|
        item.product_type.taxable_areas.each do |taxable_area|
          taxable = true if ship_to == taxable_area.region
        end
      end
      taxable
    end
  
  # Cart::Item
  # Represent an item in the cart
  # Keeps track of product_type_id and quantity
  class Item
    
    attr_reader :product_type_id
    attr_accessor :quantity
    
    def initialize(cart, product_type_id, quantity = 1)
      @cart = cart
      @product_type_id = product_type_id
      @quantity = quantity
    end
    
    # Builds a new item based on a stringified representation of
    # this cart item
    def self.build_from_session(cart, stringified_item)
      product_type_id = extract_product_type_id(stringified_item)
      quantity = extract_quantity(stringified_item)
      
      Item.new(cart, product_type_id, quantity)
    end
    
    def self.extract_product_type_id(stringified_item)
      stringified_item.split('x').first.to_i
    end
    
    def self.extract_quantity(stringified_item)
      stringified_item.split('x').last.to_i
    end
    
    # The product type associated with this cart item
    def product_type
      ProductType.find(@product_type_id)
    end
    
    # The product associated with this cart item
    def product
      product_type.product
    end
    
    # String representation of the item to be saved in the session
    def to_s
      "#{@product_type_id}x#{@quantity}" # '147x2' 2 of product_type #147
    end
    
    def increment_quantity
      @quantity += 1
    end
    
    def decrement_quantity
      @quantity -= 1
    end
    
    def none?
      @quantity == 0
    end
    
    # Get the items final price after 
    # applying coupons and gold member pricing
    def final_price
      @cart.coupon && @cart.coupon.applicable?(product_type ,@cart.user) ?
        @cart.coupon.applied_price(product_type.price) :
        users_price
    end
    
    # Gets the regular user vs. member price
    def users_price
      (@cart.is_member? && product_type.member_price) ? product_type.member_price : product_type.price
    end
    
    # Get the items final price after
    # applying coupons and gold member discounts
    def final_shipping
      if @cart.coupon
        @cart.coupon.free_shipping? ? 0.0 : product_type.shipping
      else
        users_shipping
      end
    end
    
    # Get the users shipping
    def users_shipping
      @cart.is_member? ? 0.0 : product_type.shipping
    end
  end
end


