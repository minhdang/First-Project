class Event < ActiveRecord::Base
  
  include AASM
  
  has_many :rsvps
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :current
  aasm_state :expired
  
  aasm_event :active do
    transitions :from => :pending, :to => [:active]
  end
  
  aasm_event :pending do 
    transitions :from => :current, :to => [:pending]
  end
  
  aasm_event :expired do
    transitions :from => :current, :to => [:expired]
  end
  
  named_scope :current, :conditions => ["state = ?", 'current'], :order => 'created_at DESC', :limit => 1
  named_scope :find_current, lambda { |slug| {:conditions => ["state = ? AND slug = ?", 'current',slug], :limit => 1}}
  
  def create_slug
    self.slug = "#{self.guest.parameterize}"
  end
  
end
