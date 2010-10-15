module UserSkillsHelper
  def linked_list_of_skills(user_skills)
    linked_skills = user_skills.collect do |user_skill| 
      "#{link_to(user_skill.skill.title, skill_path(user_skill.skill))}"
    end
    
    return linked_skills.to_sentence
  end
end