module MembershipsHelper
  def gold_member_link_to(text, path, options={})
    if current_user && current_user.member?
      link_to(text, path, options)
    else
      text
    end
  end
end