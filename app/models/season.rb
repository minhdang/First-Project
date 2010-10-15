class Season < ActiveRecord::Base
  acts_as_url :official_title

  has_many :episodes
  
  validates_uniqueness_of :season_number
  validates_presence_of :season_number, :description
  
  def to_param
    url
  end
  
  def official_title
    return "Everyday Edisons Season #{self.season_number}"
  end
end