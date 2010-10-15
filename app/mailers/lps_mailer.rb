class LpsMailer < ApplicationMailer  
  
  def submission_receipt(submission)
    lps = submission.live_product_search
    setup_email(submission.user)
    subject     "Edison Nation - Live Product Search Submission: #{submission.key}"
    bcc         ['legal@edisonnation.com']
    content_type    "multipart/alternative"
  
    part 'text/plain' do |p|
      p.body = render_message('submission_receipt.text.plain.erb', :submission => submission, :lps => lps)
    end
    
    part 'text/html' do |p|
      p.body = render_message('submission_receipt.text.html.erb', :submission => submission, :lps => lps)
    end
  
    attachment :content_type => "application/pdf", :filename=>"Live Product Search Innovator Agreement #{lps.title} Submission #{submission.key}.pdf", :body => File.read(submission.agreement.pdf.path) if submission.agreement && submission.agreement.pdf? && submission.agreement.pdf.exists?
  
  end

   # Sent when the status of user's submission changes
  def submission_moved(submission)
    setup_email(submission.user)
    subject         'Edison Nation - The status of your submission has changed'
    body :submission => submission
  end

end
