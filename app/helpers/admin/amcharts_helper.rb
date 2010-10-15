module Admin::AmchartsHelper
  
  def chart(data_sets, options = {})
    default_options = {
      :type             => 'amline',
      :width            => '100%',
      :height           => 300,
      :background_color => '#FFFFFF',
      :loading_settings => 'Loading Settings',
      :loading_data     => 'Loading Data',
      :decimal_places   => 0
    }
    options = default_options.merge(options)
    options[:id] ||= options[:type]
    
    output = ''
    content_for :head, javascript_include_tag('/swf/swfobject.js')
    output += content_tag(:div, :id => "#{options[:id]}_content", :class=>'chart') do
                concat content_tag(:strong, "Click to Load #{data_sets.map(&:titleize).to_sentence} Data")
              end
              
    output += content_tag(:script, :type => 'text/javascript') do
                concat "\nvar #{options[:id]} = new SWFObject("\
                        "'/swf/amcharts/#{options[:type]}/#{options[:type]}.swf','#{options[:id]}',"\
                        "'#{options[:width]}','#{options[:height]}','#{options[:background_color]}');\n"
                concat "#{options[:id]}.addVariable('path','/swf/amcharts/#{options[:type]}/');\n"
                concat "#{options[:id]}.addVariable('settings_file',encodeURIComponent('"\
                        "/swf/amcharts/#{options[:type]}/settings.xml?#{Time.now.to_i}'));\n"
                concat "#{options[:id]}.addVariable('data_file',encodeURIComponent('"\
                        "#{admin_statistics_path(:data => data_sets.join('+'), :format => :xml)}'));\n"
                concat "#{options[:id]}.addVariable('loading_settings','#{options[:loading_settings]}');\n"
                concat "#{options[:id]}.addVariable('loading_data','#{options[:loading_data]}');\n"
                concat "#{options[:id]}.addVariable('additional_chart_settings','<settings>"\
                          "<digits_after_decimal>#{options[:decimal_places]}</digits_after_decimal>"\
                        "</settings>');\n"
                concat "jQuery('##{options[:id]}_content').click(function(){#{options[:id]}.write('#{options[:id]}_content')});"
              end
    
    output
  end
  
end