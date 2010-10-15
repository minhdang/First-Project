module InsidersHelper
  
  def date_box(date)
    html = ''
    html << content_tag(:div, content_tag(:p, "#{date.strftime("%b")}"), :class => 'month')
    html << content_tag(:div, content_tag(:p, "#{date.strftime("%d")}"), :class => 'day')
    html
  end
  
end
