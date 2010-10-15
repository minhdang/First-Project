class QuestionChoice < ActiveRecord::Base
  
  belongs_to :question
  
  validates_presence_of :label
  
  def to_s
    label
  end
  
end
