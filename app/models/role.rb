class Role < ActiveRecord::Base
  
  has_and_belongs_to_many :users, :join_table => 'users_roles'
  
  validates_presence_of :name
  
  named_scope :by_name, :order => 'name'
  
  acts_as_url :name
  
  def to_param
    url
  end
end
