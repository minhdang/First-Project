class Order < ActiveRecord::Base
  require 'digest/sha1'
  include AASM
  
  belongs_to :user
  belongs_to :store
  
  has_many :order_items
  
  has_one :payment, :as => :chargeable
  accepts_nested_attributes_for :payment, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  has_one :ship_to_address, :as => :contactable, :class_name => 'ContactInformation'
  accepts_nested_attributes_for :ship_to_address, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  belongs_to :coupon
  
  validates_presence_of :number, :subtotal, :tax, :shipping, :user, :store, :payment
  validates_uniqueness_of :number
  validates_associated :payment
  validates_associated :order_items
  
  # Ship To Address Validation & Actions
  before_validation_on_create :copy_ship_to_address_from_billing, :if => :ship_to_billing?
  validates_presence_of :ship_to_address, :unless => :ship_to_billing?
  validates_associated :ship_to_address, :unless => :ship_to_billing?
  validate :validate_ship_to_address_is_acceptable
  
  before_validation_on_create :generate_order_number
  before_validation_on_create :set_payment_amount

  default_scope :order => 'created_at DESC'
  
  # Hold the cart that initialized the order
  attr_accessor :cart
  
  aasm_column :state
  aasm_initial_state :initial => :unpaid
  aasm_state :unpaid
  aasm_state :paid, :enter => :redeem_coupon
  aasm_state :processing
  aasm_state :backordered, :enter => :do_backorder, :exit => :undo_backorder
  aasm_state :shipped, :enter => :do_ship

  aasm_event :pay do
    transitions :from => :unpaid, :to => :paid, :guard => :payment_processed?
  end

  aasm_event :process do
    transitions :from => :paid, :to => :processing
  end

  aasm_event :backorder do
    transitions :from => :processing, :to => :backordered
  end

  aasm_event :exit_backorder do
    transitions :from => :backordered, :to => :processing, :guard => Proc.new {|order| order.payment && order.payment.approved? }
  end

  aasm_event :ship do
    transitions :from => [:paid, :processing], :to => :shipped
  end
  
  # Thinking Sphinx indexes
  define_index do
    # fields
    indexes [user.first_name, user.last_name], :as => :user_name
    indexes user.login, :as => :user_login
    indexes user.email, :as => :user_email
    indexes :number
  end
  
  

  # Use the order number as the params
  # makes it easier for users to understand
  # which of their orders their looking at just by
  # looking at the url.
  def to_param
    number
  end
  
  # Get this order in a csv format for the fulfillment provider
  def to_csv
    order_items.map(&:to_csv).join("\n")
  end

  # Set the carrier and tracking number, then ship!
  def ship_via(carrier, tracking_number)
    self.carrier, self.tracking_number = carrier, tracking_number
    ship! unless shipped?
  end
  
  def tracking_url
    App.shipping_carriers[carrier.to_sym]['tracking_url'] + tracking_number.to_s
  end
  
  # Build a new order based on the cart
  def self.build_from_cart(cart, attributes = {})
    order = Order.new
    order.cart      = cart
    order.subtotal  = cart.subtotal
    order.tax       = cart.tax
    order.shipping  = cart.shipping
    order.total     = cart.total
    order.coupon    = cart.coupon
    
    # Prepopulate the optional attributes
    attributes.each do |attribute, value|
      order.send("#{attribute.to_s}=".to_sym, value)
    end
    
    # Get all the items in the cart
    cart.items.each do |cart_item|
      order.order_items.build(:product => cart_item.product, :product_type => cart_item.product_type,
                              :quantity => cart_item.quantity, :price => cart_item.final_price)
    end
    
    order
  end
  
  # Has this order just now had its
  # payment processed
  def recently_paid?
    @recently_paid
  end
  
  # Has this order just now had its
  # tracking number added
  def recently_shipped?
    @recently_shipped
  end
  
  protected
    
    def generate_order_number
      while(number.blank?)
        potential_number = Digest::SHA1.hexdigest(Time.now.usec.to_s).upcase[0...8]
        self.number = potential_number unless Order.exists?(:number => potential_number)
      end
    end
    
    def do_backorder
      self.backordered_until ||= 1.week.from_now
    end
    
    def undo_backorder
      self.backordered_until = nil
    end
    
    def do_ship
      @recently_shipped = true
      self.shipped_on = Time.now.utc
    end
    
    # Attempt to process the payment if it has
    # not been done yet
    def payment_processed?
      paid? || (payment.process! && (@recently_paid = true))
    end
    
    # Set the payment amount to this orders total
    def set_payment_amount
      payment.amount = total if payment
    end
    
    # Get the ship to address from the payment
    # if the user want to ship to their billing address
    def copy_ship_to_address_from_billing
      self.build_ship_to_address(payment.billing_address.attributes) if payment && payment.billing_address
    end
    
    # Make sure the ship_to_address is acceptable
    def validate_ship_to_address_is_acceptable
      if (!ship_to_billing? && ship_to_address && ship_to_address.country != 'US') || (ship_to_billing? && payment && payment.billing_address && payment.billing_address.country != 'US')
        self.errors.add_to_base('We currently only ship orders to the United States. Please select an alternative Shipping Address')
      end
    end
    
    # Redeem the coupon if one exists
    def redeem_coupon
      coupon.redeem! if coupon
    end
end