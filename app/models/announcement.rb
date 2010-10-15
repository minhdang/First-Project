class Announcement < ActiveRecord::Base
  
  belongs_to :user
  
  named_scope :current, :order => 'updated_at DESC' 
  
end
