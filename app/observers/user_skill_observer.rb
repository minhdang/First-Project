class UserSkillObserver < ActiveRecord::Observer
  
  def after_create(user_skill)
    # Create a notice that the user has added a skill
    user_skill.user.send_later(:notice!,user_skill)
  end
  
end