class TopicView < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :topic
  
  validates_presence_of :user_id, :topic_id
  
  named_scope :for_topic, lambda{|topic| {:conditions => {:topic_id => topic.id}}}
  
end
