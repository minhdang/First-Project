module FormHelper
  
  # Display a required field legend
  # ex. * = required
  def required_field_legend
    "<span class='required'><strong>bold fields are required</strong></span>"
  end
  
  def state_select_tag(name = 'state', selected = nil)
    sorted_state_options = App.states[:US].to_a.map(&:reverse).sort {|x,y| x.first <=> y.first}
    select_tag name, options_for_select(sorted_state_options.unshift(['-- Select a State --',nil]), selected)
  end
  
  def state_selector(form_helper, html_options = {})
    form_helper.select :state, App.states[:US].sort.map {|abbr, name| [name, abbr]}, {:include_blank => '-- Select a State --'}, html_options
  end
  
  def country_selector(form_helper, html_options = {})
    priority_countries = [:US, :AU, :UK, :CA]
    countries = App.countries.stringify_keys.sort
    
    priority_countries = priority_countries.collect {|code| [App.countries[code], code]}
    countries = countries.map {|abbr, name| [name, abbr]}
    
    form_helper.select :country, priority_countries + countries, {:include_blank => '-- Select a Country --'}, html_options
  end
end