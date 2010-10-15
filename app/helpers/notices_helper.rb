module NoticesHelper
  # Generate a message based on the type of noticeable we're using
  def notice_message(notice)
    creator = notice.creator
    
    return "#{message_subject(creator)} #{notice.message}" if notice.message
    
    case notice.noticeable
    when User
      "#{message_subject(creator)} joined Edison Nation."
    when Membership
      "#{message_subject(creator)} became an #{link_to('Edison Insider',membership_path)}"
    when TopicView
      topic = notice.noticeable.topic
      "#{message_subject(creator)} viewed \"#{link_to(h(topic.title),forum_topic_path(topic.forum, topic))}\""
    when Post
      topic = notice.noticeable.topic
      "#{message_subject(creator)} replied to \"#{link_to(h(topic.title),forum_topic_path(topic.forum,topic))}\""
    when GroupMembership
      group = notice.noticeable.group
      "#{message_subject(creator)} joined the #{link_to(h(group.title), group_path(group))} group"
    when UserPhoto
      photo = notice.noticeable
      "#{message_subject(creator)} added a photo \"#{link_to(h(photo.caption), user_album_path(creator, photo.user_album))}\""
    when UserVideo
      video = notice.noticeable
      "#{message_subject(creator)} added a video \"#{link_to(h(video.title), user_video_path(creator,video))}\""
    when BlogEntry
      "#{message_subject(creator)} created a new #{link_to('blog entry', user_blog_entry_path(creator, notice.noticeable))}"
    when Friendship
      if notice.noticeable.friend
        friend = notice.noticeable.friend
        "#{message_subject(creator, ['are','is'])} now friends with #{link_to(h(friend.name), user_path(friend))}"
      end
    when Need
      need = notice.noticeable
      "#{message_subject(creator, ['need','needs'])} \"#{link_to(h(need.title), need_path(need))}\""
    when UserSkill
      skill = notice.noticeable.skill
      "#{message_subject(creator, ['are','is'])} skilled in \"#{link_to(h(skill.title), skill_path(skill))}\""
    when Education
      "#{message_subject(creator)} updated #{possessive(creator)} education information"
    when Submission
      lps = notice.noticeable.live_product_search
      "#{message_subject(creator)} submitted an idea to #{link_to(h(lps.key),live_product_search_path(lps))}"
    when Rating
      lps      = notice.noticeable.submission.live_product_search
      inventor = notice.noticeable.submission.user
      "#{message_subject(creator)} rated #{inventor.name}'s submission to #{lps.key}"
    when Comment
      inventor = notice.noticeable.idea.user
      submission = notice.noticeable.submission
      "#{message_subject(creator)} commented on #{inventor.name}'s #{submission ? ('submission to '+submission.live_product_search.key) : 'idea'}"
    when Move
      move        = notice.noticeable
      submission  = move.submission
      "#{creator.name}'s submission to #{submission.live_product_search.key} #{(move.killer? ? 'failed at' : 'passed')} '#{Submission::Stages[move.move_to]}'"
    else
      "#{message_subject(creator)} updated #{possessive(creator)} profile"
    end
  end
  
  protected
    def message_subject(creator, verbage = [])
      first_person = (creator == current_user)
      subject =  []
      subject << (first_person ? 'You' : link_to(h(creator.name),user_path(creator)))
      subject << (first_person ? verbage.first : verbage.last) unless verbage.empty?
      subject.join(' ')
    end
end