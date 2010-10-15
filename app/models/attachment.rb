class Attachment < ActiveRecord::Base
  MaxSize = 100.megabytes
  
  belongs_to :idea, :counter_cache => true
  
  has_attached_file :file,
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :s3_permissions => 'private',
    :path           => "ideas/:idea_id/attachments/:basename.:extension",
    :bucket         => App.s3[:en_bucket]
    
  Paperclip.interpolates(:idea_id) { |attachment,style| attachment.instance.idea_id }
  
  validates_attachment_presence :file
  validates_attachment_size :file, :less_than => MaxSize, :message => 'must be less than 100MB'
  
  validates_presence_of :idea_id
  
end
