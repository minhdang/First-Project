class EducationObserver < ActiveRecord::Observer
  
  def after_create(education)
    # Create a notice that the user has added a skill
    education.user.send_later(:notice!,education,true)
  end
  
end