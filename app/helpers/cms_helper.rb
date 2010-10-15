module CmsHelper
  def active_on_page(page)
    current_page = controller.action_name.to_sym
    active = current_page == page ? 'active' : nil
  end  
end