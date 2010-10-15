class Invitation < ActiveRecord::Base
  
  belongs_to :user, :foreign_key => :sender_id
  validates_presence_of :sender_id, :sent_to
  validates_uniqueness_of :sent_to, :scope => :sender_id
  validates_format_of :sent_to, :with => Authentication.email_regex, :message => Authentication.bad_email_message  

end
