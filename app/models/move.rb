class Move < ActiveRecord::Base
  include AASM
  
  Offset            = (3..6).to_a  # Spacing of moves in days
  WorkHours         = (5..15).to_a # 5AM - 3PM work days Pacific Time
  WorkWeek          = [1,2,3,4,5]  # No decisions made on Saturday or Sunday
  InvalidDates      = ['July 4th', 'December 24th', 'December 25th', 'December 31st', 'January 1st'] # No decisions made when we're not here
  
  belongs_to :submission
  belongs_to :user
  belongs_to :job, :class_name => 'Delayed::Job', :dependent => :destroy
  
  validates_presence_of :submission_id, :move_to, :move_at
  validates_uniqueness_of :move_to, :scope => :submission_id
  
  before_validation_on_create :move_to_next_stage, :unless => :move_to
  before_validation_on_create :calculate_move_at, :unless => :move_at
  
  after_create :create_job, :unless => :complete?
  after_save   :update_job
  
  before_destroy :ensure_last_move
  after_destroy  :rollback_move
  
  validate_on_create  :validate_sequential_move_to
  validate            :validate_sequential_move_at
  validate            :validate_no_presentation_conflict
  
  named_scope :to_stage, lambda {|stage|
    {:conditions => {:move_to => stage}}
  }
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :complete, :enter => :do_move
  
  aasm_event :move do
    transitions :from => :pending, :to => :complete
  end
  
  # Called by Delayed::Job - Move the submission
  def perform
    move!
  end
  
  def last_move?
    submission.last_move == self
  end
  
  def previous_move
    submission.moves.to_stage(self.move_to - 1).first
  end
  
  def next_move
    submission.moves.to_stage(self.move_to + 1).first
  end
  
  def recently_moved?
    @recently_moved
  end
  
  def killer?
    submission.dead? && submission.stage == move_to
  end
  
  protected
    # Set move_to to the next sequential stage
    def move_to_next_stage
      return unless submission
      self.move_to = submission.next_stage
    end
    
    def calculate_move_at
      return unless submission
      
      delayed_move_at = if submission.last_move
        last_move_at = submission.last_move.move_at
        delayed_time(last_move_at)
      else
        delayed_time(Time.zone.now) # There wasn't a last move so lets count out from right now.
      end
      delayed_move_at = (delayed_move_at < Time.zone.now) ? Time.zone.now : delayed_move_at
      delayed_move_at = (submission.live_product_search.presentation - 1.minute) if presentation_conflict?(delayed_move_at)
      self.move_at = delayed_move_at
    end
    
    # Gets a random time that falls within a given range of days from a start time
    # Makes sure the date is valid (no weekends, late nights, or holidays)
    def delayed_time(start = Time.zone.now)
      potential = nil
      until(valid_delayed_time?(potential))
        potential = start + Offset.shuffle.first.days # Date
        potential += rand(24).hours
        potential += rand(60).minutes
      end
      potential
    end
    
    def valid_delayed_time?(datetime)
      return false if datetime.nil?
      WorkHours.include?(datetime.hour) && WorkWeek.include?(datetime.wday) &&
      !InvalidDates.map{|d| Date.parse("#{d} #{datetime.year}")}.include?(datetime.to_date)
    end
    
    # Make sure we are not skipping any moves
    def validate_sequential_move_to
      return unless submission && move_to
      unless move_to == submission.next_stage
        errors.add(:move_to, 'must be the next stage in a submissions destiny')
      end
    end
    
    # Make sure that move at is in the correct order
    def validate_sequential_move_at
      return unless submission && previous_move
      unless move_at >= previous_move.move_at
        errors.add(:move_at, 'must be after all previous moves')
      end
    end
    
    def validate_no_presentation_conflict
      errors.add(:move_at, 'conflicts with the presentation date') if presentation_conflict?
    end
    
    # Decisions for Stages 1-7 need to be made before a presentation date while
    # a decision for Stage 8 can only be made on or after a presentation date
    def presentation_conflict?(time = move_at)
      return(false) unless move_to && time && submission && submission.live_product_search.presentation
      if move_to < Submission::LastStage
        time >= submission.live_product_search.presentation
      else
        time <  submission.live_product_search.presentation
      end
    end
    
    def do_move
      @recently_moved = true
      submission.reload # Reload just incase another move was just triggered on the submission
      
      submission.update_attribute(:visible_stage, move_to) if submission.visible_stage < move_to
     
     if move_to < submission.stage 
       #RewardPointValue.tally(submission, submission.user, move_to)
       #logger.debug '#####################################'
       #logger.debug 'Paying points on ' + move_to.to_s
       #logger.debug 'Visible stage is ' + submission.visible_stage.to_s
       #logger.debug 'Stage is ' + submission.stage.to_s
       #logger.debug '#####################################'
     elsif submission.stage == move_to && submission.alive?
       #logger.debug '#####################################'
       #logger.debug 'submission.stage == move_to && submission.alive?'
       #logger.debug '#####################################'
       #RewardPointValue.tally(submission, submission.user, move_to)
     end
     
     
     
      
      
      
    end
    
    # Create a Delayed::Job that will execute the move at the appropriate time
    def create_job
      self.job = Delayed::Job.enqueue(Move.find(id), priortity=1, run_at=move_at)
      save
    end
    
    # Make sure that if we change the move at time that the DJ knows about it
    def update_job
      return unless job
      job.update_attribute(:run_at, move_at.utc)
    end
    
    def ensure_last_move
      errors.add_to_base('Only the last move can be destroyed') unless last_move?
      last_move?
    end
    
    def rollback_move
      Submission.decrement_counter(:stage, submission_id)
      Submission.decrement_counter(:visible_stage, submission_id) if complete?
      Submission.update_all({:alive => true}, {:id => submission_id}) if submission.dead?
    end
  
end
