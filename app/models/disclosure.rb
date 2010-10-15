class Disclosure < ActiveRecord::Base
  
  belongs_to :idea
  
  validates_presence_of :idea_id
  
end
