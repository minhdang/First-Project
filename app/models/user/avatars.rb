class User
  
  has_attached_file :avatar,
                    :styles => {
                                 :crop  => "485x485",
                                 :large => "200x200#",
                                 :thumb => "100x100#",
                                 :tiny  => "44x44#",
                                 :icon  => "23x23#"
                               },
                    :default_url => "/images/avatars/default_avatar_:avatar_gender.:style.gif"
  Paperclip.interpolates(:avatar_gender) { |attachment,style| attachment.instance.avatar_gender } 
  validates_attachment_content_type :avatar, :content_type => /image/, :message => 'is not an image.'
                    
  
  # flag to let us know if the user just updated
  # their avatar so we can show the avatar cropper
  def recently_updated_avatar?
    @updated_avatar
  end
  
  # Override the paperclip attribute writer
  # so that we can flag the as being updated
  def avatar=(file)
    @updated_avatar = attachment_for(:avatar).assign(file)
  end
  
  # Crops a users avatar given a set of coordinates
  def crop_avatar!(x, y, w, h)
    # Work with integers
    x, y, w, h = x.to_i, y.to_i, w.to_i, h.to_i
    
    if img = avatar.to_file(:crop)
      img.binmode if img.respond_to?(:binmode)

      command = <<-end_command
                  "#{ File.expand_path(img.path) }[0]"
                  -crop #{w}x#{h}+#{x}+#{y} +repage
                  "#{ File.expand_path(img.path) }"
                end_command
              
      begin
        @success = Paperclip.run("convert", command.gsub(/\s+/, " "))
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error cropping the avatar for #{File.basename(img.path)}" if @whiny_thumbnails
      end
    
      if @success
        self.avatar = img
        save
        img.close
      end
    end
    
    @success
  end
  
  def avatar_gender
    gender == 'female' ? 'female' : 'male'
  end
end