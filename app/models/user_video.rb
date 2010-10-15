class UserVideo < ActiveRecord::Base
  YOUTUBE_URL = /\.+youtube\.com\/watch.+v\=([\w0-9\-]+)(&)?.*$/
  
  before_create :build_from_youtube
  
  belongs_to :user
  validates_presence_of :url
  validates_format_of :url, :with => YOUTUBE_URL, :message => "must be a YouTube url (http://www.youtube.com/watch?v=f2b1D5w82yU)"
  
  has_attached_file :screen_shot, 
    :storage => :s3,
    :path    => 'user-videos/:id/screen-shots/:style/:id.:extension',
    :url     => 'user-videos/:id/screen-shots/:style/:id.:extension',
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :styles => { :tiny => "44x44", :thumb => "100x100", :large => '698x1000>' },
    :bucket => App.s3[:en_bucket]
  
  named_scope :limited, lambda { |limit| { :limit => limit } }
  named_scope :random, :order => 'rand()'
  
  def external_id
    url.match(YOUTUBE_URL)[1] # gets 'f2b1D5w82yU' style id from http://www.youtube.com/watch?v=f2b1D5w82yU
  end
  
  private
    # populates the model using results from YouTube API
    def build_from_youtube
      ydata = YouTubeG::Client.new.video_by(external_id)
      
      self.title       = ydata.title
      self.description = ydata.description
      self.screen_shot_remote_url  = ydata.thumbnails.last.url
      self.html        = ydata.embed_html if ydata.embeddable?
      self.screen_shot = URLTempfile.new(self.screen_shot_remote_url)
    end
end
