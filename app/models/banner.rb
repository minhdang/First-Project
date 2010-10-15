class Banner < ActiveRecord::Base

  has_attached_file :ad,
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "ads/:basename.:id.:extension",
    :bucket         => App.s3[:en_bucket],
    :url            => ":s3_force_ssl_url"
    
    # Paperclip doesn't let you force ssl or let it depend on the request
    Paperclip.interpolates :s3_force_ssl_url do |attachment,style|
      "https://s3.amazonaws.com/#{App.s3[:en_bucket]}/ads/:basename.:id.:extension"
    end
    
  
  
  validates_presence_of :name
  validates_format_of :link, :with => URI.regexp(['http']), :allow_blank => true

  named_scope :random, lambda {
    last_banner = Banner.find(:first, :select => :id, :order => 'id DESC')
    max_id      = last_banner ? last_banner.id : 0
    {:conditions => ["id >= ?", rand(max_id + 1)]}
  }
  
end
