class Tag < ActiveRecord::Base
  acts_as_url :title
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  has_many :need_tags
  has_many :needs, :through => :need_tags

  def self.search(title)
    find(:all, :conditions => ['title LIKE ?', "#{title}%"], :limit => 5)
  end

  def self.popular_need_tags
    find(:all, :limit => App.max[:popular_need_tags], :order => 'needs_count DESC')
  end
end
