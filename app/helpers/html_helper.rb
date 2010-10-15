module HtmlHelper
  def active_if_here(matches)
    current_controller = controller.controller_name.to_sym
    current_action     = controller.action_name.to_sym
    
    sections =  case matches
                when Hash
                  matches
                when Array
                  s = {}
                  matches.each {|c| s[c] = :all}
                  s
                else
                  {matches => :all}
                end
    
    #sections = matches.kind_of?(Array) ? matches : [] << matches
    
    active = nil
    sections.each do |controller, actions|
      actions = ([] << actions) unless actions.kind_of?(Array)
      active = ' active' if current_controller == controller && (actions.include?(:all) || actions.include?(current_action))
    end
    active
  end  
end