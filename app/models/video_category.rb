class VideoCategory < ActiveRecord::Base
  acts_as_url :title, :sync_url => true
  
  has_many :videos

  validates_presence_of :title

  def to_param
    url
  end
end
