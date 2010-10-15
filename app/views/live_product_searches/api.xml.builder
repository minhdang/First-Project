atom_feed do |feed|
  feed.title("Live Product Search")
  feed.updated(@lps.first.created_at)

  @lps.each do |lps|
    feed.entry(lps) do |entry|
      entry.lps_id lps.id 
      entry.title "#{lps.title.titleize}"
      entry.launch_date lps.launch
      entry.deadline_date lps.deadline
      entry.sponsor do |sponsor|
        sponsor.id   lps.sponsor.id
        sponsor.name lps.sponsor.name
        sponsor.logo("http://#{request.host}#{lps.sponsor.logo.url(:large)}")
      end
    end
  end
end