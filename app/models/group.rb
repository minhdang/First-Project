class Group < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User'
  has_many :group_memberships, :dependent => :destroy
  has_many :moderators, :through => :group_memberships, :source => :user, :conditions => ["group_memberships.moderator = ? && group_memberships.state = ?", true, 'active']
  has_many :members,    :through => :group_memberships, :source => :user, :conditions => "group_memberships.state = 'active'"
  has_many :notices, :as => :noticeable, :dependent => :destroy
  
  has_one :forum, :as => :discussable, :dependent => :destroy
  
  validates_presence_of :title, :owner
  
  after_create :create_membership_for_owner
  
  acts_as_url :title
  
  attr_protected :owner, :url, :members_count
  
  named_scope :by_popularity, :order => 'members_count DESC'
  named_scope :limited, lambda {|max| {:limit => max}}
  
  before_create {|group| group.build_forum(:name => "#{group.title} - Group Forum")}
  
  # Thinking Sphinx indexes
  define_index do
    # fields
    indexes :title, :sortable => true
    indexes :description
    
    # attributes
    has :private
  end
  
  # Count the number of accepted members
  # cache it as members_count
  def count_members
    update_attribute(:members_count, members.count)
  end
  
  def to_param
    url
  end
  
  def to_s
    title
  end
  
  # Normalize the website to a url
  def website=(url)
    url = "http://#{url}" unless url.blank? || url.match(/^[a-zA-Z]+:\/\//)
    self[:website] = url
  end
  
  def public?
    !private?
  end
  
  def discussion_is_editable_by?(user)
    user.member_of?(self)
  end
  
  protected
    def create_membership_for_owner
      membership = owner.join_group(self)
      membership.update_attribute(:moderator, true)
    end
end
