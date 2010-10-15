atom_feed do |feed|
  feed.title("EN Recent Notices")
  feed.updated(@notices.first ? @notices.first.created_at : Time.zone.now)

  @notices.each do |notice|
    feed.entry(notice) do |entry|
      entry.title "#{notice.noticeable_type.titleize} Notice for #{notice.user.name}"
      entry.content notice_message(notice), :type => 'html', :rel => notice.noticeable_type

      entry.author do |author|
        author.name("http://#{request.host}#{notice.user.avatar.url(:thumb)}")
      end
    end
  end
end