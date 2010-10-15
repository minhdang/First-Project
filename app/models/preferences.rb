class Preferences < ActiveRecord::Base
  
  belongs_to :user
  validates_presence_of :user
  
  before_save :serialize_muted_users
  before_save :serialize_muted_topics
  
  # View a list of forums by default or a list of recently updated topics
  def forums_view_mode
    self[:forums_view_mode] || App.forums[:view_mode]
  end
  
  # How many forum posts to display per page
  def per_page
    self[:per_page] || App.per_page[:default]
  end
  
  # Posts display order
  def posts_order
    self[:posts_order] || App.forums[:order]
  end
  
  # Muted Users - Muted users posts are minimized
  def muted_users
    @muted_users ||=  (self[:muted_users].blank? ? [] : YAML.load(self[:muted_users]))
  end
  
  # Muted Topics - Muted topics show up in the users trash
  def muted_topics
    @muted_topics ||=  (self[:muted_topics].blank? ? [] : YAML.load(self[:muted_topics]))
  end
  
  # Is this the default choice for a given preference?
  def default?(preference)
    self.send(preference.to_sym) == self.class.new.send(preference.to_sym)
  end
  
  protected
    def serialize_muted_users
      self[:muted_users] = muted_users.to_yaml unless muted_users.empty? && self[:muted_users].blank?
    end
    
    def serialize_muted_topics
      self[:muted_topics] = muted_topics.to_yaml unless muted_topics.empty? && self[:muted_topics].blank?
    end
end
