class TempAttachment < Attachment
  
  has_attached_file :file,
    :path           => ":rails_root/tmp/uploads/:id/:basename.:extension"
    
  validates_attachment_presence :file
  validates_attachment_size :file, :less_than => MaxSize, :message => 'must be less than 100MB'  
  
  # Save this as a regular attachment on s3
  after_post_process :mark_as_recently_uploaded
  after_save :queue_move_to_s3, :if => :recently_uploaded?
  
  def recently_uploaded?
    @recently_uploaded
  end
  
  def move_to_s3
    temp_path = file.path
    temp_dir = File.dirname(temp_path)
    temp_file = file.to_file
    
    # Save it as a regular attachment
    # this will save to S3
    s3_attachment = ::Attachment.find(id) 
    s3_attachment.file = temp_file
    s3_attachment.save!
    
    # Ensure the attachment made it to S3
    # if we throw an error delayed_job will try again
    raise AttachmentNotMovedError unless s3_attachment.file.exists?
    
    # Delete the temporary file when we are done
    temp_file.close
    File.delete(temp_path)
    Dir.delete(temp_dir)
  end
  
  protected
  
    def mark_as_recently_uploaded
      @recently_uploaded = true
    end

    def queue_move_to_s3
      send_later(:move_to_s3)
    end
  
end

class AttachmentNotMovedError < StandardError; end