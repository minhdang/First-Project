class Contributor < ActiveRecord::Base
  
  belongs_to :idea
  
  has_one :contact_information, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contact_information
  
  validates_presence_of :idea_id
  
end
