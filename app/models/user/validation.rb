class User

  
  validates_presence_of     :login,     :unless => :initial_signup  
  validates_length_of       :login,     :within => 3..40, :unless => :initial_signup
  validates_uniqueness_of   :login,     :unless => :initial_signup
  validates_format_of       :login,     :with => Authentication.login_regex,
                            :message => Authentication.bad_login_message, :unless => :initial_signup
  
  validates_presence_of     :first_name
  validates_length_of       :first_name,     :maximum => 50, :allow_blank => true
  validates_presence_of     :last_name
  validates_length_of       :last_name,      :maximum => 50, :allow_blank => true
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  validates_length_of       :new_email, :within => 6..100, :allow_blank => true
  validates_format_of       :new_email, :with => Authentication.email_regex, :message => Authentication.bad_email_message, :allow_blank => true
  
  validate :provides_current_password, :if => :password_required?
  
  # Make a new user aggree to our TOS
  attr_accessor :terms_of_service
  attr_accessible :terms_of_service
  validates_acceptance_of :terms_of_service, :on => :create
  
  # Have a tiered validation so we can check
  # for a valid user along seperate steps
  # of the signup process
  attr_accessor :initial_signup
  
  protected
    
    def provides_current_password
      return true if new_record? || password.blank? || editing_in_admin || resetting_password
      unless self.authenticated?(self.current_password)
        self.errors.add(:current_password, 'must match your current password')
      end
    end
    
    def password_required?
      (crypted_password.blank? || !password.blank?) && !initial_signup
    end
  
end