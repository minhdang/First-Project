class UserPhoto < ActiveRecord::Base
  belongs_to :user_album
  has_one    :user, :through => :user_album, :source => :user
  validates_presence_of :caption, :user_album_id, :url
  
  acts_as_url :caption

  has_attached_file :src, :styles => { :tiny => "44x44", :thumb => "100x100", :large => '698x1000>' }, 
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "albums/:user_album_id/photos/:style/:id.:extension",
    :bucket         => App.s3[:en_bucket]
  Paperclip.interpolates(:user_album_id) { |attachment,style| attachment.instance.user_album_id }  
  
  validates_attachment_presence :src

  named_scope :limited, lambda { |limit| { :limit => limit } }
  named_scope :random, :order => 'rand()'

  def to_param
    url
  end

end