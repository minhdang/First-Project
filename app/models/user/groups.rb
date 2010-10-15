class User
  
  has_many :group_memberships, :dependent => :destroy
  has_many :groups, :through => :group_memberships, :conditions => "group_memberships.state = 'active'"
  
  # Make the user join a group
  def join_group(group)
    GroupMembership.create(:user => self, :group => group)
  end
  
  # Is this user a member of a particular group
  def member_of?(group)
    group_ids.include?(group.id)
  end
  
  # Get this users membership for a particular group
  def membership_for(group)
    group_memberships.find(:first, :conditions => {:group_id => group.id}, :order => 'id DESC')
  end
  
  def group_owner?(group)
    id == group.owner_id
  end
end