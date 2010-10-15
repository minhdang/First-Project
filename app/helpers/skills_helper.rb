module SkillsHelper
  def add_or_remove_skill_button(skill)
    if current_user.has_skill?(skill)
      button_to 'Remove Skill', user_skill_path(current_user, skill), :method => :delete, :class => 'delete-user-skill-button', :confirm => "Are you sure you want to remove #{skill.title} from your skills?"
    else
      add_skills_button
    end
  end
  
  def add_skills_button
    link_to 'Add Skills', edit_user_path(current_user), :class => 'add-user-skill-button'
  end
end
