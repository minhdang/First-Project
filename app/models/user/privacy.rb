class User
  
  attr_accessible :contact_public, :education_public, :photos_public, :work_public, :videos_public, :blog_public, :needs_public
  has_viewable_resources :contact, :education, :photos, :work, :videos, :blog, :needs
  
  def resource_viewable_by?(user, resource_public)
    return resource_public if user.nil?
    resource_public || user.admin? || friends_with?(user) || self == user
  end
end
