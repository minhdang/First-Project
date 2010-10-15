class Episode < ActiveRecord::Base
  has_many :chapters
  has_one :first_chapter, :class_name => 'Chapter', :order => 'chapter_number'
  belongs_to :season
  
  has_attached_file :image,
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "seasons/:season_id/episodes/:id/image/:id.:extension",
    :bucket         => App.s3[:en_bucket]

  Paperclip.interpolates(:season_id) { |attachment,style| attachment.instance.season_id }    

  validates_presence_of :title, :description, :episode_number, :season_id
  validates_uniqueness_of :episode_number, :scope => :season_id
  
  named_scope :limited, lambda { |n| { :limit => n } }
  named_scope :active, :conditions => { :active => true }
  
  def season_sequence
    "#{season.season_number}#{'%02d' % episode_number}"
  end
end