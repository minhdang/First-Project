module VideosHelper
  def free_video_message(video, message)
    if video.free? && (!logged_in? || (current_user && !current_user.member?))
      message += link_to(" Learn more about becoming an Insider &rsaquo;", lounge_path)
    end
  end
  
  def display_video(video)
    render :partial => 'shared/video_player', :locals => { :video_path => video.url(:original, include_time_stamps = false) }
  end
  
  def list_episode_chapters(episode, current_chapter=nil)
    episode.chapters.collect do |c| 
      content_tag(:li) do
        link_to "Chapter #{c.chapter_number}", season_episode_chapter_path(@season, @episode, c), :class=> current_chapter == c ? 'active' : nil
      end
    end
  end
end