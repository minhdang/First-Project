class Rsvp < ActiveRecord::Base
  
  include AASM
  
  belongs_to :user
  belongs_to :event
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :active
  aasm_state :expired
  
  aasm_event :active do
    transitions :from => :pending, :to => [:active]
  end
  
  aasm_event :pending do 
    transitions :from => :active, :to => [:pending]
  end
  
  aasm_event :expired do
    transitions :from => :active, :to => [:expired]
  end
  
end
