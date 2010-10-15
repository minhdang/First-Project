class SystemMailer < ApplicationMailer
  
  def attached_file(path, options = {})
    file        = File.new(path)
    options     = {:recipients => App.admin_email, :subject => "Edison Nation Attachment"}.merge(options)
    recipients  options[:recipients]
    from        App.admin_email
    subject     options[:subject]
  
    attachment :content_type => "text/csv", :filename => File.basename(file.path), :body => file.read
  end
end