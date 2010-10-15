class Lead < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :campaign, :counter_cache => true
  
  has_many :actions
  
  validates_presence_of   :campaign
  validates_uniqueness_of :key
  
  before_create :generate_key
  
  named_scope :converted, :conditions => 'user_id IS NOT NULL'
  
  named_scope :by_month, lambda { |month| { :conditions => [ self.active_month(month) ], :order => 'created_at DESC' }}
  
  named_scope :since, lambda {|whenever|
    {:conditions => ["created_at >= ?", whenever.utc]}
  }
  
  named_scope :by_month, lambda { |month| { :conditions => [ self.active_month(month) ], :order => 'created_at DESC' }}
  
  named_scope :within_campaigns, lambda {|campaigns|
    {:conditions => {:campaign_id => campaigns.map(&:id)}}
  }
  
  def to_param
    key
  end
  
  def track(action_type, data = {})
    actions.create({
      :action_type => action_type.to_s,
      :data        => data
    })
  end
  
  def self.active_month(month)
    "created_at BETWEEN '10-#{month}-01' AND '10-#{month}-31'"
  end
  
  protected
  
    def generate_key
      while key.blank? || Lead.exists?(:key => key)
        self.key = ActiveSupport::SecureRandom.hex(6)
      end
    end
  
end
