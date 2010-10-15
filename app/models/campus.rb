class Campus < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  
  has_many :educations
  has_many :users, :through => :educations
  has_many :majors, :through => :educations
  has_many :minors, :through => :educations
  
  acts_as_url :title
  
  def to_param
    url
  end
  
  def concentrations
    (majors + minors).uniq.sort_by {|concentration| concentration.title}
  end
  
  def self.search(title)
    find(:all, :conditions => ['title LIKE ?', "%#{title}%"], :limit => 5)
  end
  
  def self.find_popular
    find(:all, :order => 'users_count DESC', :limit => App.max[:popular_campuses])
  end
end