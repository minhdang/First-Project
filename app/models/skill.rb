class Skill < ActiveRecord::Base
  has_many :user_skills, :dependent => :destroy
  has_many :users, :through => :user_skills
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  acts_as_url :title
  
  def self.search(title)
    find(:all, :conditions => ['title LIKE ?', "#{title}%"], :limit => 5)
  end
  
  def self.popular_skills
    find(:all, :order => 'users_count DESC', :conditions => 'users_count >= 1', :limit => App.max[:popular_user_skills])
  end
  
  def to_param
    url
  end
end