class Video < ActiveRecord::Base
  belongs_to :video_category

  validates_presence_of :title, :description
  
  has_attached_file :image,
    :storage => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "video-categories/:video_category_id/videos/:id/image/:basename.:id.:extension",
    :url            => "video-categories/:video_category_id/videos/:id/image/:basename.:id.:extension",
    :bucket         => App.s3[:en_bucket]
    
  has_attached_file :video,
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "video-categories/:video_category_id/videos/:id/:basename.:id.:extension",
    :url           => "video-categories/:video_category_id/videos/:id/:basename.:id.:extension",
    :bucket         => App.s3[:en_bucket]
    
    Paperclip.interpolates(:video_category_id) {|attachment, style| attachment.instance.video_category_id }
  
  default_scope :order => 'created_at ASC'
  
  named_scope :active, :conditions => { :active => true }
  named_scope :limited, lambda { |limit| { :limit => limit } }
end
