class Action < ActiveRecord::Base
  
  belongs_to :lead
  
  validates_presence_of :action_type
  
  serialize :data, Hash
  
end
