class Topic < ActiveRecord::Base
  include AASM

  after_create   :create_initial_post
  after_create   :activate!
  before_update  :check_for_moved_forum
  after_update   :set_post_forum_id
  before_destroy :count_user_posts_for_counter_cache
  after_destroy  :update_cached_forum_and_user_counts
  
  before_validation_on_create :set_default_attributes

  # creator of forum topic
  belongs_to :user

  # creator of recent post
  belongs_to :last_user, :class_name => "User"

  belongs_to :forum, :counter_cache => true

  has_many :posts,       :order => "posts.created_at", :dependent => :delete_all
  has_one  :fresh_post,  :order => "posts.updated_at DESC", :class_name => 'Post'
  has_one  :recent_post, :order => "posts.id DESC", :class_name => "Post"
  has_one  :first_post,  :conditions => {:first_post => true}, :class_name => "Post"
  has_one  :last_post,   :class_name => 'Post'
  has_many :replies,     :conditions => {:first_post => false}, :class_name => "Post"

  has_many :voices, :through => :posts, :source => :user, :uniq => true

  has_many :monitorships, :dependent => :delete_all
  has_many :monitoring_users, :through => :monitorships, :source => :user, :conditions => {"monitorships.active" => true}

  validates_presence_of :user_id, :forum_id, :title
  validates_presence_of :body, :on => :create

  attr_accessor :body
  attr_accessible :title, :body

  attr_readonly :posts_count, :hits

  acts_as_url :title, :scope => :forum_id
  
  named_scope :main, :include => :forum, :conditions => ["forums.discussable_type IS ? && forums.discussable_id IS ?", nil, nil]
  named_scope :newest_first, :order => "topics.created_at DESC"
  named_scope :recently_updated, :order => "topics.last_updated_at DESC"
  named_scope :ordered, :order => "topics.sticky desc, topics.last_updated_at desc"
  named_scope :created_after, lambda {|time| {:conditions => ["created_at > ?", time]}}
  
  aasm_column :state
  aasm_initial_state :initial => :pending
  aasm_state :pending
  aasm_state :active
  aasm_state :spam

  aasm_event :activate do
    transitions :from => [:pending, :spam], :to => :active
  end
  
  aasm_event :spam do
    transitions :from => [:pending, :active, :spam], :to => :spam
  end

  def to_s
    title
  end

  def sticky?
    sticky == 1
  end

  def hit!
    self.class.increment_counter :hits, id
  end

  def update_cached_post_fields(post)
    reload # Make sure we do not cache recent_post
    # these fields are not accessible to mass assignment
    if remaining_post = post.frozen? ? recent_post : post
      self.class.update_all(['last_updated_at = ?, last_user_id = ?, last_post_id = ?, posts_count = ?', 
        remaining_post.updated_at, remaining_post.user_id, remaining_post.id, posts.count], ['id = ?', id])
    else
      self.destroy
    end
  end

  def to_param
    url
  end
  
  # Is this editable by a particular user
  def editable_by?(user, is_moderator = nil)
    # is_moderator = user.moderator_of?(forum) if is_moderator.nil?
    user && (user.id == user_id || is_moderator)
  end
  
  def postable_by?(user)
    !locked? && (!forum.is_discussion? || forum.discussable.discussion_is_editable_by?(user))
  end

  protected
    def create_initial_post
      post = user.reply_to_topic self, @body #unless locked?
      
      # label this post as the first so we can easily 
      # display it on each page without screwing up pagination
      post.update_attribute(:first_post, true)
      
      @body = nil
    end

    def set_default_attributes
      self.sticky          ||= 0
      self.last_updated_at ||= Time.now.utc
    end
    
    def check_for_moved_forum
      old = Topic.find(id)
      @old_forum_id = old.forum_id if old.forum_id != forum_id
      true
    end

    def set_post_forum_id
      return unless @old_forum_id
      posts.update_all :forum_id => forum_id
      Forum.update_all "posts_count = (posts_count - #{posts_count}), topics_count = (topics_count - 1)", ['id = ?', @old_forum_id]
      Forum.update_all "posts_count = (posts_count + #{posts_count}), topics_count = (topics_count + 1)", ['id = ?', forum_id]
    end

    def count_user_posts_for_counter_cache
      @user_posts = posts.group_by { |p| p.user_id }
    end

    def update_cached_forum_and_user_counts
      Forum.update_all "posts_count = posts_count - #{posts_count}", ['id = ?', forum_id]
      @user_posts.each do |user_id, posts|
        User.update_all "posts_count = posts_count - #{posts.size}", ['id = ?', user_id]
      end
    end
  
end
