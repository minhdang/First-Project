class GroupMembership < ActiveRecord::Base
  include AASM
  
  belongs_to :group
  belongs_to :user
  
  validates_presence_of :group, :user
  validates_uniqueness_of :user_id, :scope => :group_id
  
  before_create :activate_membership_if_public_group_or_owner
  after_destroy :decrement_members_count, :if => :active?
  after_destroy :assign_new_owner, :if => :owner?
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :active, :enter => :do_activate, :exit => :decrement_members_count
  aasm_state :denied
  aasm_state :suspended
  aasm_state :canceled
  
  aasm_event :activate do
    transitions :from => :pending, :to => :active
  end
  
  aasm_event :deny do
    transitions :from => :pending, :to => :denied
  end
  
  aasm_event :suspend do
    transitions :from => :active, :to => :suspended
  end
  
  aasm_event :cancel do
    transitions :from => :active, :to => :canceled
  end
  
  def recently_activated?
    @recently_activated
  end
  
  def owner?
    !user.blank? && user.group_owner?(group)
  end
  
  protected
    def do_activate
      increment_members_count
      @recently_activated = true
    end
  
    def increment_members_count
      group.increment!(:members_count)
    end
    
    def decrement_members_count
      group.decrement!(:members_count)
    end
    
    def activate_membership_if_public_group_or_owner
      self.activate if group.public? || user == group.owner
    end
    
    def assign_new_owner
      new_owner = group.members.reject { |member| member == group.owner }.first
      if new_owner
        group.update_attribute(:owner_id, new_owner.id)
      else
        group.destroy
      end
    end
end
