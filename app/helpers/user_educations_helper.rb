module UserEducationsHelper
  
  def linked_list_of_campuses(educations)
    list = educations.map do |education| 
      education_link = link_to education.campus.title, campus_path(education.campus)
      delete_link = link_to('X', user_education_path(current_user, education), :confirm => 'Are you sure you want to delete this education?', :method => :delete, :class => 'delete-button')
      "#{education_link} #{delete_link}"
    end
    
    list.to_sentence
  end
  
end