module Admin::PagesHelper
  
  def nested_page_list(pages)
    return '' if pages.empty?
    
    content_tag(:ul) do
      list = ''
      
      pages.each do |page|
        list << content_tag(:li, :class => (page.published? ? 'published' : 'draft')) do
          list_item = link_to(page.title, admin_page_path(page))
          list_item << content_tag(:div, :class => 'meta') do
            meta = "Updated #{time_ago_in_words(page.updated_at)}. "
            meta << link_to('edit', edit_admin_page_path(page))
            meta << ' | '
            meta << link_to('destroy', admin_page_path(page), :method => :delete)
          end
          list_item << nested_page_list(page.children.ordered.all)
        end
      end
      
      list
    end
  end
  
  def pages_for_select(pages, depth = 0)
    options = []
    
    pages.each do |page|
      options << ["--" * depth + page.title, page.id]
      options += pages_for_select(page.children, depth + 1) if page.children.any?
    end
    
    options
  end
  
end