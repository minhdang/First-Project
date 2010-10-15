class Campaign < ActiveRecord::Base
  
  has_many :leads, :order => 'id DESC', :dependent => :destroy
  
  validates_presence_of   :title, :target
  validates_uniqueness_of :key
  validates_format_of     :target, :with => /^https?:\/\//
  
  before_create :generate_key
  
  default_scope :order => 'id DESC'
  
  def to_param
    key
  end
  
  def track_lead(request)
    return unless trackable?(request)
    
    leads.create do |lead|
      lead.referrer   = request.referer
      lead.ip_address = request.remote_ip
      lead.user_agent = request.env['HTTP_USER_AGENT']
    end
  end
  
  protected
  
    def trackable?(request)
      !request.referer.to_s.match(/#{request.host}\/admin/) &&
      !request.env['HTTP_USER_AGENT'].to_s.match(/AdsBot-Google/)
    end
  
    def generate_key
      while key.blank? || Campaign.exists?(:key => key)
        self.key = ActiveSupport::SecureRandom.hex(3)
      end
    end
  
end
