class User
  
  include AASM
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :passive
  aasm_state :pending, :enter => :do_register
  aasm_state :active,  :enter => :do_activate, :exit => :uncheck_active
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete

  aasm_event :register do
    transitions :from => :passive, :to => :active,
      :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) && !App.send_account_activation_email}
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  aasm_event :activate do
    transitions :from => [:pending, :deleted], :to => :active
  end
  
  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def recently_registered?
    @registered
  end
  
  # The available states that a user is either in or
  # is able to transition to
  def available_states
    states =  []
    states << :passive if passive?
    states << :pending if passive? || pending?
    states << :active
    states << :suspended unless deleted?
    states << :deleted
    states
  end
  
  # Move to the appropriate state if available
  def move_to_state(s)
    case s.to_sym
    when :pending
      register if passive?
    when :active
      activate if pending? || deleted?
      unsuspend if suspended?
    when :suspended
      suspend if passive? || pending? || active?
    when :deleted
      delete if passive? || pending? || active? || suspended?
    end
  end
  
  protected
    def do_delete
      membership.cancel! if member?
      group_memberships.destroy_all
      friendships.destroy_all
      submissions.destroy_all
      user_skills.destroy_all
      needs.destroy_all
      educations.destroy_all
      created_notices.destroy_all
      monitorships.destroy_all
      self.deleted_at = Time.now.utc
    end
    
    def do_register
      make_activation_code
      @registered = true
    end

    def do_activate
      @activated = true
      self.active = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end
    
    def uncheck_active
      self.active = false
    end
  
end