class Store < ActiveRecord::Base
  
  has_many :products, :dependent => :destroy
  has_many :product_types
  has_many :orders
  
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  acts_as_url :name
  
  def to_param
    url
  end
  
end
