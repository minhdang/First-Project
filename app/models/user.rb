require 'digest/sha1'

class User < ActiveRecord::Base
  # Split out specific business logic to seperate files
  # - located in app/models/users/*concerened_with*.rb
  

  
  
  concerned_with  :validation, :authentication, :states, :searching, :friendships,
                  :avatars, :groups, :forums, :skills, :contact_information,
                  :privacy, :badges, :roles, :magazine_subscription, :notices, :live_product_searches
  
  has_one  :preferences, :dependent => :destroy
  has_one  :membership, :order => 'id DESC'
  has_many :memberships, :dependent => :destroy 
  
  
  has_many :user_albums, :dependent => :destroy
  has_many :user_photos, :through => :user_albums
  has_many :user_videos, :dependent => :destroy
  has_many :blog_entries, :as => :bloggable, :dependent => :destroy
  has_many :needs, :dependent => :destroy
  has_many :educations, :dependent => :destroy
  has_many :invitations, :foreign_key => 'sender_id'
  has_many :messages, :dependent => :destroy
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id', :dependent => :destroy
  has_many :orders
  has_many :survey_responses
  
  has_many :leads
  has_many :campaigns, :through => :leads
  
  has_many :submission_coupons, :through => :submissions, :source => :coupon, :conditions => ["submissions.state = ?", 'complete']
  has_many :order_coupons, :through => :orders, :source => :coupon, :conditions => "orders.state != 'unpaid'"
  
  has_many :logins
  
  has_many :announcements
  
  has_many :rsvps
    
  before_save  :remove_current_badge_if_doesnt_have_badge, :if => :current_badge
  after_create :clear_password
  
  attr_accessible :login, :new_email, :first_name, :last_name, :current_password, :password, :password_confirmation, :avatar, :mailable
  
  # Virtual attribute used when user is changing their password
  attr_accessor :current_password
  
  # Let the model know if we're editing this user in the admin
  attr_accessor :editing_in_admin, :resetting_password
  
  named_scope :newest_first, :order => "id DESC"
  named_scope :random, :order => 'rand()'
  named_scope :limited, lambda{|limit| {:limit => limit}}
  named_scope :admin, :conditions => {:admin => true}
  named_scope :activated_on, lambda{|date| {:conditions => ["activated_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day]}}
  named_scope :member, :conditions => {:member => true}
  named_scope :active_on, lambda {|date| {:conditions => ["activated_at <= ? AND state = 'active'", date]}}
  named_scope :actived_on, lambda {|date| {:conditions => ["activated_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day]}}
  named_scope :mailable, :conditions => {:state => 'active', :mailable => true}
  
  # Make login display as Username in form errors
  HUMANIZED_ATTRIBUTES = {
    :login => "Username"
  }
  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
  
  def self.change_in_users(start_date, finish_date)
    active_on(start_date).count - active_on(finish_date).count
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def short_name
    "#{first_name} #{last_name.first.upcase}."
  end
  
  # Use their login as their id
  def to_param
    login
  end
  
  # flag to let us know if the user has recently updated
  # their email address so we can send an activation email
  def recently_updated_email?
    @updated_email
  end
  
  # Set the new email address and create an activation code
  # so the user can confirm the new email account
  def new_email=(new_email)
    unless email == new_email
      self[:new_email] = new_email
      @updated_email = new_email
      make_activation_code
    end
  end
  
  # Set the new email address to be the current one
  def activate_new_email!
    self.email            = self.new_email
    self.new_email        = nil
    self.activation_code  = nil
    save
  end
  
  def forgot_password?
    @forgot_password
  end
  
  # Generate a reset code to let the user reset their password
  def forgot_password!
    self.reset_code = self.class.make_token
    @forgot_password = true
    save!
  end

  # Does this user have an opinion on a given preference
  def has_preference?(preference)
    self.preferences && !preferences.default?(preference.to_sym)
  end
  
  def upgrade!(payment_attributes)
    build_membership
    payment                   = Payment.new(payment_attributes)
    payment.billing_address   = ContactInformation.new(payment_attributes[:billing_address_attributes])
    membership.payment        = payment
    membership.cost           = App.membership_cost
    membership.save! && membership.activate!
  end
  
  def coupons
    submission_coupons + order_coupons
  end
  
  def log(request)
    begin
      self.logins.create do |log|
        log.ip_address    = request.remote_ip
        log.user_agent    = request.env['HTTP_USER_AGENT']
        log.platform      = request.user_agent_info['platform']
        log.name          = request.user_agent_info['name']
        log.name_display  = request.user_agent_info['name_display']
        log.os            = request.user_agent_info['cpuos']
        log.language      = request.user_agent_info['language']
        log.version       = request.user_agent_info['version']
        log.engine        = request.user_agent_info['engine']
      end
    rescue
      self.logins.create do |log|
        log.ip_address    = 'unable to parse request'
        log.user_agent    = 'unable to parse request'
        log.platform      = 'unable to parse request'
        log.name          = 'unable to parse request'
        log.name_display  = 'unable to parse request'
        log.os            = 'unable to parse request'
        log.language      = 'unable to parse request'
        log.version       = 'unable to parse request'
        log.engine        = 'unable to parse request'
      end
    end
  end
  
  def rsvped_for(event)
    rsvp = self.rsvps.find_by_event_id(event.id)
    if rsvp 
      return true
    else
      return false
    end
  end

  protected
    def clear_password
      self.password = nil
    end
    
    def remove_current_badge_if_doesnt_have_badge
      self.current_badge = nil unless badges.include?(current_badge)
    end
end