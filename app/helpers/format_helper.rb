module FormatHelper
  
  def boolean_flag(bool, text = nil)
    "<span class='flag #{bool.to_s}#{ ' labeled' unless text.nil?}'>#{text || bool.to_s}</span>"
  end
  
  def yes_or_no(bool)
    bool ? 'Yes' : 'No'
  end
  
  def timeago(datetime)
    content_tag(:abbr, datetime.to_s(:long), :class => 'timeago', :title => datetime.utc.iso8601)
  end
  
  def na(text = nil)
    text.blank? ? '<em>n/a</em>' : text
  end
  
  def midnight_or_full_time(time)
    time == time.end_of_day ? "Midnight on #{time.to_s(:date_ordinal)}" : time.to_s(:full_ordinal)
  end
  
  def nl2br(text)
    text.gsub("\n",'<br/>')
  end
  
  def wrap(txt, col = 80)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
      "\\1\\3\n") 
  end
  
  def en_format(content)
    # Allow only tags specified
    content = sanitize(content, :tags => %w(b strong i em img a), :attributes => %w(src href))
    # Support Line Breaks
    content = simple_format(content)
    # Add Auto Links
    content = auto_link(content, :all, :target=>'_blank')
    # Return content
    return content
  end
  
end