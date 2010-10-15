class Login < ActiveRecord::Base
  
  belongs_to :user
  
  named_scope :last_ten, :order => "id DESC", :limit => 10
  
end
