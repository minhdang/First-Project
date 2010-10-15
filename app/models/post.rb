class Post < ActiveRecord::Base
  include AASM
  
  # formats all links posted in forums with rel='nofollow'
  no_follows :body

  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic, :counter_cache => true
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  belongs_to :moderator, :class_name => 'User'
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked
  
  after_create  :update_cached_fields
  after_create  :activate!
  after_destroy :update_cached_fields

  attr_accessible :body
  
  named_scope :recently_updated, :order => 'updated_at DESC'
  named_scope :recent, lambda{ {:conditions => ["created_at >= ?", 25.minutes.ago], :limit => 5} }
  named_scope :created_after, lambda {|time| {:conditions => ["created_at > ?", time]}}
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :active, :enter => :do_activate
  aasm_state :spam, :enter => :do_spam

  aasm_event :activate do
    transitions :from => [:pending, :spam], :to => :active
  end
  
  aasm_event :spam do
    transitions :from => [:pending, :active, :spam], :to => :spam
  end
  
  # Thinking Sphinx indexes
  define_index do
    # fields
    indexes :body
    indexes topic.title, :as => :topic_title
    indexes forum.name,  :as => :forum_name
    indexes [user.first_name, user.last_name],   :as => :author_name
    indexes user.login,  :as => :author_login
    
    # attributes
    has :first_post
    has :state
    has forum.discussable_id, :as => :discussable_id
  end
  
  # Is this editable by a particular user
  def editable_by?(user, is_moderator = nil)
    # is_moderator = user.moderator_of?(forum) if is_moderator.nil?
    user && (user.id == user_id || is_moderator)
  end
  
  # Increment this comments spam counter and mark as spam if past the threshold
  def spam_hit!(moderator)
    do_spam if moderator
    self.increment!(:spam_count)
    self.spam! if !spam? && spam_count >= App.forums[:spam_threshold]
  end
  
  def spammed?
    @spammed
  end

protected
  def update_cached_fields
    topic.update_cached_post_fields(self)
  end
  
  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic && topic.locked? && topic.posts_count > 0
  end
  
  def do_activate
    self.spam_count = 0
  end
  
  def do_spam
    @spammed = true
    topic.spam! if first_post?
  end
  
end
