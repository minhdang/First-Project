class User
  
  belongs_to :current_badge, :class_name => 'Badge'
  has_and_belongs_to_many :badges, :join_table => :users_badges
  
  def assign_badge!(badge)
    badges << badge unless badges.include?(badge)
    update_attribute(:current_badge, badge) if (current_badge.nil? || (badge > current_badge))
  end
  
  def remove_badge!(badge)
    badges.delete(badge) if badges.include?(badge)
    update_attribute(:current_badge, badges.max) if current_badge == badge
  end
  
end