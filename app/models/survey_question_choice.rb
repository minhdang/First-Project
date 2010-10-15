class SurveyQuestionChoice < ActiveRecord::Base
  
  belongs_to :survey_question
  
  validates_presence_of :survey_question_id, :label
  
end
