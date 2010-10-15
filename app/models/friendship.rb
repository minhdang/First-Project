class Friendship < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  belongs_to :friend, :class_name => 'User', :foreign_key => :friend_id
  
  validates_presence_of :user, :friend
  validates_uniqueness_of :friend_id, :scope => [:user_id, :state], :unless => :denied?
  
  named_scope :newest_first, :order => 'id DESC'
  
  aasm_column :state
  aasm_initial_state :pending
  
  aasm_state :pending
  aasm_state :accepted, :enter => :do_accept
  aasm_state :denied, :enter => :do_deny
  
  aasm_event :accept do
    transitions :to => :accepted, :from => :pending
  end
  
  aasm_event :deny do
    transitions :to => :denied, :from => [:pending, :accepted]
  end
  
  # The mirrored friendship
  def mirror
    @mirror ||= Friendship.find(:first, :conditions => {:user_id => friend.id, :friend_id => user.id}, :order => 'id Desc')
  end
  
  def recently_accepted?
    @recently_accepted
  end
  
  protected
    def do_accept
      @recently_accepted = true
      Friendship.create(:user => friend, :friend => user, :state => 'accepted')
    end
    
    def do_deny
      # Call update instead of deny so we don't get into a back and forth argument
      mirror.update_attribute(:state, 'denied') if mirror
    end
end
