class Concentration < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  
  has_many :major_educations, :class_name => 'Education', :foreign_key => 'major_id'
  has_many :minor_educations, :class_name => 'Education', :foreign_key => 'minor_id'
  
  def self.search(title)
    find(:all, :conditions => ['title LIKE ?', "#{title}%"], :limit => 5)
  end

end
