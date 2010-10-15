class Issue < ActiveRecord::Base
  acts_as_url :title
  
  formats_attributes :description

  validates_presence_of :title, :description, :short_description, :published_at
  
  has_attached_file :pdf, 
    :storage => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "issues/:id/:basename.:extension",
    :url            => "issues/:id/:basename.:extension",
    :bucket         => App.s3[:en_bucket],
    :styles => { :thumb  => ['120x156#', :png] }
  
  named_scope :active, :conditions => { :active => true }

  def self.latest
    find(:first, :order => 'published_at DESC', :conditions => { :active => true })
  end

end
