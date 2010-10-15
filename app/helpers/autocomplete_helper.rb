module AutocompleteHelper

  def autocomplete_javascript
    javascript_include_tag('jquery/jquery.autocomplete.js', 'autocomplete')    
  end
  
  def autocomplete_css
    stylesheet_link_tag('autocomplete')
  end
end