class QuestionMailer < ApplicationMailer  
  
  def message(message_body,login,first_name,last_name,user_email)
     recipients      'video.conference@edisonnation.com'
     from            user_email
     sent_on         Time.now
     subject         "#{first_name} #{last_name} ask a question at" + " " + Time.now.to_s
     body            message_body
   end

end