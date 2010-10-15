module UserVideosHelper
  
  def title_as_edit_link_if_owner(user_video)
    if current_user == user_video.user
      link_to user_video.title, edit_user_video_path(user_video.user, user_video)
    else
      link_to user_video.title, user_video_path(user_video.user, user_video)
    end
  end
  
  def embed_video(user_video)
    if user_video.html
      user_video.html
    else
      link_to image_tag(user_video.screen_shot.url, :alt => user_video.title), user_video.url, :target => '_blank'
    end
  end

end
