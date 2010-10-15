class SurveyQuestion < ActiveRecord::Base
  
  belongs_to :survey
  has_many :choices, :class_name => 'SurveyQuestionChoice'
  
  validates_presence_of :survey_id, :label, :question_type
  validates_inclusion_of :question_type, :in => Question::Types.values
  
end