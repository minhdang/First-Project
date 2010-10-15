class TaxableArea < ActiveRecord::Base
  
  has_and_belongs_to_many :product_types
  
  validates_presence_of :country, :region, :rate
  validates_numericality_of :rate
  
end
