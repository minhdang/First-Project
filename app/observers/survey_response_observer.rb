class SurveyResponseObserver < ActiveRecord::Observer

  def after_save(survey_response)
    # Send a Receipt to the user for their records
    if survey_response.recently_completed?
      # Don't want this block to run multiple times
      survey_response.instance_variable_set(:@recently_completed, false)
      
      # Send out the survey_response receipt
      SurveyMailer.deliver_survey_response_receipt(survey_response)
    end
  end
  
end
