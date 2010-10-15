class Product < ActiveRecord::Base
  
  belongs_to :store
  belongs_to :category, :class_name => 'ProductCategory', :foreign_key => :product_category_id, :counter_cache => true
  has_many   :types, :class_name => 'ProductType', :dependent => :destroy
  has_many   :order_items
  has_many   :orders, :through => :order_items, :source => :orders
  
  formats_attributes :description, :detailed_description
  acts_as_url :name
  
  validates_presence_of :name, :store, :description, :detailed_description, :category
  
  named_scope :in_category, lambda{|category| {:conditions => ["product_category_id = ?", category.id]}}
  
  def to_param
    url
  end
end
