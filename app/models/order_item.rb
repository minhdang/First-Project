class OrderItem < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :product
  belongs_to :product_type
  
  validates_presence_of :product, :product_type, :quantity
  
  def to_csv
    csv =  []
    csv << order.number
    csv << product_type.sku
    csv << quantity
    csv << order.created_at.strftime('%m/%d/%Y')
    csv << order.ship_to_address.first_name
    csv << order.ship_to_address.last_name
    csv << order.ship_to_address.address_1
    csv << order.ship_to_address.address_2
    csv << order.ship_to_address.city
    csv << order.ship_to_address.state
    csv << order.ship_to_address.postal_code
    csv << order.ship_to_address.country
    csv.map{|entry| entry.to_s.strip.gsub(',','') }.join(',')
  end
  
  def name
    "#{product.name}-#{product_type.name}"
  end
  
end
