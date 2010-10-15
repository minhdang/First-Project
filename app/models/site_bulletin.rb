class SiteBulletin < ActiveRecord::Base
  include AASM
  
  
  
  aasm_column :state
  aasm_initial_state :initial => :draft
  aasm_state :draft
  aasm_state :published
  aasm_state :archived
  
  aasm_event :draft do
    transitions :from => [:published, :archived], :to => :draft
  end
  
  aasm_event :publish do
    transitions :from => [:draft, :archived], :to => :published
  end
  
  aasm_event :archive do
    transitions :from => [:draft, :published], :to => :archived
  end
  
  
  named_scope :current, lambda {
    {:conditions => ["state = ?", 'published']}
  }
  
  
  def available_states
    return [:archived] if archived?
    available = [:published, :archived, :draft]
  end
  
  def move_to_state(s)
    s = s.to_sym   
    case s
    when :draft
      self.draft! unless draft?
    when :published
      self.publish! unless published? 
    when :archived
      self.archive! unless archived?
    end
  end
  
end
