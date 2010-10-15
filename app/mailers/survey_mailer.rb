class SurveyMailer < ApplicationMailer  
  
  def survey_response_receipt(survey_response)
    setup_email(survey_response.user)
    subject     "Edison Nation - Name Search: Response ##{survey_response.id}"
    bcc         ['legal@edisonnation.com']
    body        :survey => survey_response.survey, :response => survey_response
  end

end
