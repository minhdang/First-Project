class ProductCategory < ActiveRecord::Base
  
  acts_as_url :name
  has_many :products
  
  def to_param
    url
  end
  
end
