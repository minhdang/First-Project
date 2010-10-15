class User
  
  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships, :conditions => "friendships.state = 'accepted' AND users.state = 'active'"
  has_many :friend_requests, :class_name => 'Friendship', :foreign_key => 'friend_id', :conditions => {:state => 'pending'}
  has_many :sent_friend_requests, :class_name => 'Friendship'
  has_many :received_friend_requests, :class_name => 'Friendship', :foreign_key => 'friend_id', :dependent => :destroy
  
  # Returns a friendship that relates to another user if one exist
  def friendship_with(another_user)
    options = {:conditions => "state != 'denied'", :order => "id DESC"}
    Friendship.newest_first.find_by_user_id_and_friend_id(self.id, another_user.id, options) ||
    Friendship.newest_first.find_by_user_id_and_friend_id(another_user.id, self.id, options)
  end
  
  def friends_with?(another_user)
    another_user && Friendship.exists?(:user_id => self.id, :friend_id => another_user.id, :state => 'accepted')
  end
  
  # Default friendship with the team account. Everybody gets one friend.
  def create_friendship_with_team
    friendship = Friendship.new(:user => User.find_by_login('enteam'), :friend => self)
    friendship.accept!
  end
  
  def sent_friend_request?(friendship)
    friendship.user_id == id
  end
  
  def received_friend_request?(friendship)
    friendship.friend_id == id
  end
  
end