class UserAlbum < ActiveRecord::Base
  belongs_to :user
  has_many :user_photos, :dependent => :destroy
  
  validates_presence_of :title, :user_id
  
  acts_as_url :title, :scope => :user_id, :sync_url => true
  
  def to_param
    url
  end
end
