class ProductType < ActiveRecord::Base
  
  belongs_to :store
  belongs_to :product
  
  has_and_belongs_to_many :taxable_areas
  
  acts_as_url :sku, :sync_url => true
  
  validates_presence_of :name, :sku, :store, :product
  validates_uniqueness_of :sku
  
  def to_param
    url
  end
  
end
