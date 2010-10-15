class ApplicationMailer < ActionMailer::Base
  helper_method :site, :signature
  
  def test(email)
    recipients  email
    from        App.admin_email
    sent_on     Time.now
    subject     "EN - Test Email"
    body        "This is a test"
  end
  
  protected
    def setup_email(user)
      recipients    "#{user.email}"
      from          App.admin_email
      sent_on       Time.now
      body          :user => user
    end
    
    def site
      "http://#{App.domain}"
    end
    
    def signature
      sig = ""
      sig << "Edison Nation Team\n"
      sig << "support@edisonnation.com\n"
      sig << "http://support.edisonnation.com"
    end
end