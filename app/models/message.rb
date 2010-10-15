class Message < ActiveRecord::Base  
  belongs_to :sender, :class_name => "User", :foreign_key => 'sender_id'
  belongs_to :user
  validates_presence_of :user_id, :sender_id, :body
  validate :max_amount_of_messages_sent
  
  attr_accessor :skip_limit_check
  
  protected
    def max_amount_of_messages_sent
      max_reached = self.class.count(:conditions => ['sender_id = ? AND created_at >= ?', sender_id, 1.day.ago]) >= App.max_emails_sent_per_day
      if !skip_limit_check && max_reached
        errors.add_to_base("Cannot be sent due to max messages being reached")
      end
      !max_reached
    end
end
