class Notice < ActiveRecord::Base
  include ActionController::UrlWriter
  include ActionView::Helpers::UrlHelper
  
  belongs_to :user
  belongs_to :creator, :class_name => 'User'
  belongs_to :noticeable, :polymorphic => true
  
  validates_uniqueness_of :user_id, :scope => [:creator_id, :noticeable_type, :noticeable_id]
  
  before_create :populate_user, :unless => :user
  before_create :decide_if_public_notice
  after_create :replicate_notice, :if => :replicate?
  
  named_scope :similar, lambda {|noticeable|
    {:conditions => {:creator_id => noticeable.user.id, :noticeable_type => noticeable.class.name}}
  }
  named_scope :today, lambda {
    {:conditions => ["created_at > ?",Time.now.beginning_of_day]}
  }
  named_scope :original, :conditions => 'creator_id = user_id'
  named_scope :limit, lambda {|l| {:limit => l}}
  named_scope :ordered, :order => 'created_at DESC'
  named_scope :ignore_enteam, :conditions => ['creator_id != ?', 1]
  named_scope :created_after, lambda {|datetime|
    {:conditions => ['created_at > ?', datetime]}
  }
  named_scope :public_notice, :conditions => {:public_notice => true}
  named_scope :with_complex_index, :from => 'notices USE INDEX (index_notices_on_creator_id_and_user_id_and_created_at)'
  
  def self.already_noticed?(noticeable)
    Notice.exists?(:user_id => noticeable.user, :creator_id => noticeable.user, :noticeable_type => noticeable.class.name, :noticeable_id => noticeable.id)
  end
  
  def original_notice?
    user && creator && user == creator
  end
  
  def notify_users(users)
    users.each do |u|
      unless u.id == creator.id
        notice      = self.clone
        notice.user = u
        notice.save
      end
    end
  end
  
  protected
    def replicate?
      original_notice? && public_notice?
    end
  
    def populate_user
      self.user = creator
    end
    
    # Send this notice to all the
    # users who will find it relevant
    def replicate_notice
      users = case noticeable
              # Notify people who follow a topic
              when Post 
                noticeable.topic.monitoring_users
              # Notify people who are the member of a group plus the creator's friends
              when GroupMembership
                (noticeable.group.members + creator.friends).uniq
              when Friendship
                creator.friends.reject {|u| u == noticeable.friend}
              # Notify the friends of the creator
              else
                creator.friends
              end
      self.notify_users(users) if users.size <= App.max_users_to_notify
    end
    
    def decide_if_public_notice
      return unless public_notice.nil?
      public_noticeables = [User, Membership, Post, GroupMembership, UserPhoto, UserVideo,
        BlogEntry, Friendship, Need, UserSkill, Education, Submission]
      self.public_notice = public_noticeables.include?(noticeable.class)
    end
  
end