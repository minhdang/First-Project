class Forum < ActiveRecord::Base
  
  acts_as_list
  acts_as_url :name
  formats_attributes :description
  
  has_many :topics, :order => "topics.sticky desc, topics.last_updated_at desc", :dependent => :delete_all
  has_many :recent_topics, :class_name => 'Topic', :include => [:user], :order => "topics.last_updated_at DESC", :conditions => ["users.state == ?", "active"]
  has_one  :recent_topic,  :class_name => 'Topic', :order => "#{Topic.table_name}.last_updated_at DESC"

  has_many :posts,       :order => "#{Post.table_name}.created_at DESC", :dependent => :delete_all
  has_one  :recent_post, :order => "#{Post.table_name}.created_at DESC", :class_name => 'Post'
  
  belongs_to :discussable, :polymorphic => true
  
  validates_presence_of :name
  
  attr_readonly :posts_count, :topics_count
  
  named_scope :ordered, :include => :recent_topic, :order => 'topics.last_updated_at DESC'
  named_scope :positioned, :order => 'forums.position'
  named_scope :main, :conditions => ["discussable_type IS ? && discussable_id IS ?", nil, nil]
  named_scope :official, :conditions => {:official => true}
  named_scope :unofficial, :conditions => {:official => false}
  
  def to_param
    url
  end

  def to_s
    name
  end
  
  def editable_by?(user)
    (official? && user.admin?) || (!official? && discussable.blank?) || (discussable && discussable.discussion_is_editable_by?(user))
  end
  
  def is_discussion?
    discussable
  end
  
  def discussables_path
    return unless discussable
    case discussable
    when Group
      groups_path
    end
  end
  
  def discussable_path
    return unless discussable
    case discussable
    when Group
      group_path(discussable)
    end
  end
end
