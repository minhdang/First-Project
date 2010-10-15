atom_feed do |feed|
  feed.title("Inventors Digest Issues")
  feed.updated(@issues.first.created_at)

  @issues.each do |issue|
    feed.entry(issue) do |entry|
      entry.issue_id issue.id
      entry.title "#{issue.title.titleize}"
      entry.description issue.description
      entry.url issue.url
      entry.file_size issue.pdf_file_size
      entry.file_name issue.pdf_file_name
      entry.published_at issue.published_at
      entry.created_at issue.created_at
      entry.updated_at issue.pdf_updated_at
    end
  end
end