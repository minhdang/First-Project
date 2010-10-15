module ForumsHelper
  def forums_search_box
    content_tag :form, :action => posts_path, :method => :get, :id => 'search-forums' do
      concat text_field_tag(:q, nil, :id => 'search-box')
      concat submit_tag('Search', :class => 'search-button button green medium right')
    end
  end
  
  def discussables_link(forum)
    case discussable = forum.discussable
    when Group
      link_to 'Groups', groups_path
    else
      link_to 'Forums', forums_path
    end
  end
  
  def discussable_link(forum)
    case discussable = forum.discussable
    when Group
      link_to h(discussable.title), group_path(discussable)
    else
      link_to h(forum.name), forum_path(forum)
    end
  end
  
  def discussable_sidebar(discussable)
    case discussable
    when Group
      render :partial => 'groups/sidebar', :locals => {:group => discussable}
    else
      nil
    end
  end
  
  def forum_post_actions(post, search_results)
    # Don't try to find the forum and topic
    # if their already in an instance variable
    forum = @forum || post.forum
    topic = @topic || post.topic
    
    content_tag :span, :class => 'post-actions' do
      actions =  ""
      actions << button_to('report this post', spam_forum_topic_post_path(forum, topic, post), :method => :put, :id => dom_id(post,:spam), :class => 'mark-as-spam', :confirm => 'Are you sure you wish to report this post?') unless search_results
      actions << "First post in this topic" if search_results && post.first_post?
      concat actions
    end
  end
end
