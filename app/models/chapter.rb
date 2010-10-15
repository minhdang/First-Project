class Chapter < ActiveRecord::Base
  belongs_to :episode
  
  validates_presence_of :episode_id, :chapter_number
  
  has_attached_file :video, 
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "seasons/:season_number/episodes/:episode_id/chapters/:chapter_number.:extension",
    :bucket         => App.s3[:en_bucket]

  Paperclip.interpolates(:episode_id) { |attachment,style| attachment.instance.episode.episode_number }
  Paperclip.interpolates(:chapter_number) { |attachment,style| attachment.instance.chapter_number }
  Paperclip.interpolates(:season_number) { |attachment,style| attachment.instance.episode.season_id }    

  def to_param
    chapter_number.to_s
  end

end
