class Sponsor < ActiveRecord::Base
  
  has_attached_file :logo, :styles => {:large => '180x180', :thumb => '92x92>', :tiny => '100x20>'}, :default_style => :thumb
  validates_attachment_presence :logo
  validates_attachment_content_type :logo, :content_type => /image/, :message => 'is not an image.'
  
  validates_presence_of :name, :initials
  validates_uniqueness_of :initials
  validates_format_of :initials, :with => /^[A-Z0-9\-_]*$/, :message => 'must only contain letters, numbers, dashes, and underscores'
  
  before_validation :upcase_initials, :if => :initials
  
  has_many :live_product_searches
  
  named_scope :with_published_searches,
    :joins => "INNER JOIN live_product_searches ON live_product_searches.sponsor_id = sponsors.id", 
    :conditions => ["live_product_searches.state = 'published' && live_product_searches.launch <= ?", Time.zone.now],
    :select => "sponsors.*, count(live_product_searches.id) as published_lps_count, max(live_product_searches.launch) as latest_launch",
    :group => "live_product_searches.sponsor_id HAVING published_lps_count > 0",
    :order => "latest_launch DESC"
  
  def to_param
    initials
  end
  
  protected
  
    def upcase_initials
      initials.upcase!
    end
  
end
