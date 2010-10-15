module PagesHelper
  
  def nested_page_nav(pages, context_page)
    return '' if pages.empty?
    
    content_tag(:ul) do
      nav = ''
      
      pages.each do |page|
        nav << content_tag(:li, :class => active_if_page(page)) do
          nav_item  = link_to_page(page)
          nav_item << nested_page_nav(page.children.published.ordered.all, context_page) unless context_page.siblings.include?(page)
          nav_item
        end
      end
      
      nav
    end
  end
  
  def link_to_page(page)
    link_to page.title, page_path(page.full_path)
  end
  
  def active_if_page(page)
    controller.controller_name == 'pages' && controller.action_name == 'show' &&
      @page == page && 'active'
  end
  
  def get_snippet(page)
    snippet = Page.find_by_url('snippets')
    if snippet
      page = snippet.children.find_by_url(page) 
      page.try :body_html
    end
  end
  
end