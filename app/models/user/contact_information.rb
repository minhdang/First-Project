class User
  
  has_one  :contact_information, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contact_information
  
  attr_accessible :contact_information_attributes
  
  def address_1
    contact_information && contact_information.address_1
  end
  
  def address_2
    contact_information && contact_information.address_2
  end
  
  def city
    contact_information && contact_information.city
  end
  
  def region
    contact_information && contact_information.state
  end
  
  def country
    contact_information && contact_information.country
  end
  
  def postal_code
    contact_information && contact_information.postal_code
  end
  
  def phone
    contact_information && contact_information.phone
  end
  
  def gender
    contact_information && contact_information.gender
  end
  
  def website
    contact_information && contact_information.website
  end
  
end