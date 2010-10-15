class Need < ActiveRecord::Base
  belongs_to :user
  has_many :need_tags, :dependent => :destroy
  has_many :tags, :through => :need_tags
  
  validates_presence_of :title, :details, :user
  
  acts_as_url :title  

  proxy_attributes do
    by_string :tags => :title
  end
  
  define_index do
    indexes title
    indexes details
    indexes location
    indexes tags.title, :as => :tags
    indexes [user.first_name, user.last_name], :as => :user_name
  end
  
  
  def to_param
    url
  end
   
end