module Admin::SubmissionsHelper
  
  def insider_flag(user)
    if user
      content_tag(:span, 'insider')
    end
  end
  
end