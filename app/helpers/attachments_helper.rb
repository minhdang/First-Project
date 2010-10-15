module AttachmentsHelper
  
  def filetype_icon(attachment)
    img = case attachment.file_content_type
          when /photoshop/
            'psd'
          when /image/
            'image'
          when /video/
            'video'
          when /pdf/
            'pdf'
          when /audio/
            'audio'
          when /msword/
            'doc'
          when /gzip/
            'archive_old'
          when /zip|tar/
            'archive'
          else
            'unknown'
          end
          
    image_tag("filetypes/#{img}.png", :alt => "#{img} file type icon")
  end
  
end
