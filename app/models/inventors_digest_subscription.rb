class InventorsDigestSubscription < ActiveRecord::Base
  
  has_one :mailing_address, :as => :contactable, :class_name => 'ContactInformation', :dependent => :destroy
  accepts_nested_attributes_for :mailing_address, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  belongs_to :user
  
  validates_presence_of :user, :mailing_address
  validates_associated :mailing_address
  validates_uniqueness_of :user_id
  
end
