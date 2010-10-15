module Admin::LiveProductSearchHelper
  
  def submission_calendar(submission, date)
    date      = date.to_date
    months    = %w(January February March April May June July August September October November December)
    wdays     = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
    month     = months[date.month - 1]
    year      = date.year
    days      = (date.beginning_of_month..date.end_of_month)
    padding   = days.first.wday, (42 - days.to_a.size - days.first.wday)
    moves     = {}
    submission.moves.each {|m| moves[m.move_at.to_date] = m}
    blocks    = []
    
    padding.first.times do |t|
      blocks << content_tag(:abbr, wdays[t].first, :class => 'wday', :title => wdays[t])
    end
    
    days.each do |d|
      blocks << if moves.keys.include?(d)
        move    = moves[d]
        status  = submission.status_for_stage(move.move_to)
        content_tag(:abbr, move.move_to, :class => "#{d.to_s(:db)} move #{status}", :title => "#{status.titleize} Stage #{move.move_to}")
      else
        content_tag(:abbr, d.day, :class => "#{d.to_s(:db)} #{(d == Date.today ? 'today' : nil)}", :title => d.to_s(:date_ordinal))
      end
    end
    
    next_wday = (days.last.wday + 1) % 7
    remaining_blocks = 42 - blocks.size
    remaining_blocks.times do |t|
      blocks << content_tag(:abbr, wdays[next_wday].first, :class => 'wday', :title => wdays[next_wday])
      next_wday = (next_wday + 1) % 7
    end
    
    content_tag :table, :class => 'calendar' do
      content =   content_tag(:thead) do
        content_tag :tr do
          content_tag(:th, "#{month} #{year}", :colspan => 7)
        end
      end
      content <<  content_tag(:tbody) do
        tbody = ''
        6.times do |r|
          tbody << content_tag(:tr) do
            tr = ''
            7.times do |c|
              tr << content_tag(:td, blocks.shift)
            end
            tr
          end
        end
        tbody
      end
      content
    end
  end
  
end