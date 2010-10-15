class Education < ActiveRecord::Base
  validates_presence_of :user_id, :year
  validates_presence_of :campus_title, :on => :create
  validates_numericality_of :year
  validates_length_of :year, :is => 4
  
  belongs_to :user
  belongs_to :campus, :counter_cache => 'users_count' # campus.users_count increments and decrements when an education is created and destroyed
  belongs_to :major, :class_name => "Concentration", :foreign_key => "major_id"
  belongs_to :minor, :class_name => "Concentration", :foreign_key => "minor_id"
  
  attr_accessor :campus_title, :major_concentration_title, :minor_concentration_title
  
  def campus_title=(campus_title)
    @campus_title = campus_title
    self.campus = Campus.find_or_create_by_title(@campus_title)
  end
  
  def major_concentration_title=(major_title)
    @major_concentration_title = major_title
    self.major = Concentration.find_or_create_by_title(major_title)
  end
  
  def minor_concentration_title=(minor_title)
    @minor_concentration_title = minor_title
    self.minor = Concentration.find_or_create_by_title(minor_title)
  end
end