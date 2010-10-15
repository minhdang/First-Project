class User
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login_or_email, password, state = :active)
    return nil if login_or_email.blank? || password.blank?
    u = find_in_state :first, state, :conditions => ["login = ? OR email = ?", login_or_email, login_or_email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  protected
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end
  
end