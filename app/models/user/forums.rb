class User
  
  has_many :posts, :order => "posts.created_at desc", :dependent => :destroy
  has_many :topics, :order => "topics.created_at desc", :dependent => :destroy
  has_many :topic_views, :dependent => :destroy
  has_many :viewed_topics, :through => :topic_views, :source => :topic
  
  has_many :monitorships, :dependent => :delete_all
  has_many :monitored_topics, :through => :monitorships, :source => :topic, :conditions => {"monitorships.active" => true}
  
  # Creates new topic and post.
  # Only..
  #  - sets sticky/locked bits if you're a moderator or admin 
  #  - changes forum_id if you're an admin
  #
  def post_to_forum(forum, attributes)
    attributes.symbolize_keys!
    Topic.new(attributes) do |topic|
      topic.forum = forum
      topic.user  = self
      revise_topic topic, attributes, moderator_of?(forum)
    end
  end

  def reply_to_topic(topic, body)
    returning topic.posts.build(:body => body) do |post|
      post.forum = topic.forum
      post.user  = self
      post.save
    end
  end
  
  def revise(record, attributes)
    is_moderator = moderator_of?(record.forum)
    return unless record.editable_by?(self, is_moderator)
    case record
      when Topic then revise_topic(record, attributes, is_moderator)
      when Post  then record.update_attributes(attributes)
      else raise "Invalid record to revise: #{record.class.name.inspect}"
    end
    record
  end
  
  def seen!
    now = Time.now.utc
    self.class.update_all ['last_seen_at = ?', now], ['id = ?', id]
    write_attribute :last_seen_at, now
  end
  
  def moderator_of?(forum)
    admin?
  end
  
  def moderate!(post)
    post.moderator = self
    post.spam!
  end
  
  def monitor_topic(topic)
    returning self.monitorships.build do |monitorship|
      monitorship.topic = topic
      # Make sure ActiveRecord doesn't issue a rollback when return false from a callback
      # In this case we return false on before_create when there is an inactive monitorship
      # that already exists and we just make it active. Calling just save will issue a SQL Rollback.
      monitorship.save_without_transactions
    end
  end
  
  def monitors_topic?(topic)
    self.monitored_topic_ids.include?(topic.id)
  end
  
  # Get the last time this user viewed a topic, if ever
  def topic_last_viewed_at(topic)
    topic_view = topic_views.for_topic(topic).first
    topic_view && topic_view.last_viewed_at
  end
  
  def view_topic!(topic)
    seen!
    topic_view = topic_views.for_topic(topic).first || topic_views.build
    topic_view.topic = topic
    topic_view.increment(:views_count)
    topic_view.previous_last_viewed_at = topic_view.last_viewed_at
    topic_view.last_viewed_at = last_seen_at
    topic_view.save!
  end

protected
  def revise_topic(topic, attributes, is_moderator)
    topic.title = attributes[:title] if attributes.key?(:title)
    topic.sticky, topic.locked = attributes[:sticky], attributes[:locked] if is_moderator
    topic.save
  end
end