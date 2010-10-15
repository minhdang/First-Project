class Page < ActiveRecord::Base
  
  acts_as_url :title
  
  belongs_to :parent, :class_name => 'Page'
  has_many   :children, :class_name => 'Page', :foreign_key => :parent_id
  
  validates_presence_of :title, :body
  
  before_save :cache_textile
  
  default_scope :order => 'title ASC'
  named_scope :top,       :conditions => "parent_id IS NULL"
  named_scope :published, :conditions => {:published => true}
  named_scope :ordered,   :order => :title
  
  def to_param
    url
  end
  
  def ancestors
    parent ? ([parent] + parent.ancestors) : []
  end
  
  def siblings
    parent ? (parent.children - [self]) : []
  end
  
  def root
    ancestors.last || self
  end
  
  def full_path
    (ancestors.reverse << self).map(&:url).join('/')
  end
  
  protected
    def cache_textile
      self.body_html = RedCloth.new(body.to_s).to_html
    end
  
end
