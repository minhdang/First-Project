module LiveProductSearchHelper
  
  def open_if(condition)
    condition ? 'open' : nil
  end
  
  def setup_for_ip(idea)
    returning(idea) do |i|
      i.issued_patents.build if i.issued_patents.empty?
      i.pending_patents.build if i.pending_patents.empty?
      i.disclosures.build if i.disclosures.empty?
      if i.contributors.empty?
        contributor = i.contributors.build
        contributor.build_contact_information
      end
    end
  end
  
  def remove_resource_link(fields)
    if fields.object.new_record?
      out = link_to_function("#{t('en.common.remove')}", "$(this).parents('.nested_resource').remove();")
    else
      out = ''
      out << fields.hidden_field(:_delete)
      out << link_to_function("#{t('en.common.remove')}", "$(this).parents('.nested_resource').hide(); $(this).prev().attr('value', '1');")
      out
    end
  end
  
  def add_issued_patent_link(name, form)
    link_to_function name do |js|
      idea    = form.object
      content = render(:partial => 'new_issued_patent', :locals => {:idea_form => form, :patent => idea.issued_patents.build}) 
      js << %{
        var new_issued_patent_id = new Date().getTime();
        $('#issued_patents').append("#{ escape_javascript content }".replace(/\\[\\d+\\]/g, "["+new_issued_patent_id+"]").replace(/_\\d+_/g, "_"+new_issued_patent_id+"_"));
        activateDatepicker();
      }
    end
  end
  
  def add_pending_patent_link(name, form)
    link_to_function name do |js|
      idea    = form.object
      content = render(:partial => 'new_pending_patent', :locals => {:idea_form => form, :patent => idea.pending_patents.build}) 
      js << %{
        var new_pending_patent_id = new Date().getTime();
        $('#pending_patents').append("#{ escape_javascript content }".replace(/\\[\\d+\\]/g, "["+new_pending_patent_id+"]").replace(/_\\d+_/g, "_"+new_pending_patent_id+"_"));
        activateDatepicker();
      }
    end
  end
  
  def add_disclosure_link(name, form)
    link_to_function name do |js|
      idea    = form.object
      content = render(:partial => 'new_disclosure', :locals => {:idea_form => form, :disclosure => idea.disclosures.build}) 
      js << %{
        var new_disclosure_id = new Date().getTime();
        $('#disclosures').append("#{ escape_javascript content }".replace(/\\[\\d+\\]/g, "["+new_disclosure_id+"]").replace(/_\\d+_/g, "_"+new_disclosure_id+"_"));
        activateDatepicker();
      }
    end
  end
  
  def add_contributor_link(name, form)
    link_to_function name do |js|
      idea    = form.object
      contributor = idea.contributors.build
      contributor.build_contact_information
      content = render(:partial => 'new_contributor', :locals => {:idea_form => form, :contributor => contributor}) 
      js << %{
        var new_contributor_id = new Date().getTime();
        $('#contributors').append("#{ escape_javascript content }".replace(/\\[\\d+\\]/g, "["+new_contributor_id+"]").replace(/_\\d+_/g, "_"+new_contributor_id+"_"));
      }
    end
  end
  
  def add_choice_link(name, form)
    link_to_function name, :class => 'add-choice-button' do |js|
      question    = form.object
      choice      = question.choices.build
      content = render(:partial => 'new_choice', :locals => {:question_form => form, :choice => choice})
      js << %{
        var new_choice_id = new Date().getTime();
        $(this).parent().find('.choices').append("#{ escape_javascript content }".replace(/\\[\\d+\\]/g, "["+new_choice_id+"]").replace(/_\\d+_/g, "_"+new_choice_id+"_"));
      }
    end
  end
  
  def checklist(idea, options = {})
    lps = options[:lps]
    submission = options[:submission]
    submission ||= idea.submission_for(lps) if lps
    
    header =  content_tag(:h2, (lps ? 'Submission Checklist' : t('ideas.checklist.idea_checklist')))
    list   =  content_tag(:ul, :id => 'checklist') do
      html =  content_tag(:li, nil, :class => 'first')
      html << checklist_step(t('ideas.checklist.my_idea'), !idea.new_record?,
        (!idea.new_record? && (lps ? edit_live_product_search_idea_path(lps, idea) : edit_idea_path(idea))),
        active_if_here(:ideas => [:new, :edit, :create]))
      html << checklist_step(t('ideas.checklist.intellectual_property'), idea.ip_complete,
        (!idea.new_record? && (lps ? intellectual_property_live_product_search_idea_path(lps, idea) : intellectual_property_idea_path(idea))),
        active_if_here(:ideas => :intellectual_property))
      html << checklist_step(t('ideas.checklist.attach_media'), idea.attachments.any?,
        (idea.ip_complete? && (lps ? live_product_search_idea_attachments_path(lps, idea) : idea_attachments_path(idea))),
        active_if_here(:attachments))
      
      if lps
        if lps.questions.any?
          html << checklist_step('Sponsor Questions', (submission && submission.answers.any?),
            (idea.attachments.any? && edit_live_product_search_idea_submission_path(lps, idea)),
            active_if_here(:submissions => :edit))
        end
        html << checklist_step('Contact Info/Agreement', (submission && submission.complete?),
          idea.complete? && agreement_live_product_search_idea_submission_path(lps, idea),
          active_if_here(:submissions => :agreement))
      end
      
      html << content_tag(:li, nil, :class => 'last')
      
      html
    end
    header + list
  end
  
  def checklist_step(name, complete, link, active = nil)
    classes = (complete ? 'complete' : nil)
    classes = classes.to_s + active if active
    content_tag(:li, :class => classes) do
      link ? link_to(name, link) : "<span>#{name}</span>"
    end
  end
  
  def linked_sponsor_logo(sponsor, options = {})
    options.reverse_merge!(:style => :thumb)
    logo = image_tag(sponsor.logo.url(options[:style]), :alt => sponsor.name)
    sponsor.website.blank? ? logo : link_to(logo, sponsor.website, :target => '_blank', :class => 'sponsor-logo')
  end
  
  def thermo(submission, style = 'thermo-large')
    content_tag(:ul, :class => "thermo #{style}") do
      list = ''
      
      1.upto(8) do |stage|
        list_class =  "stage-#{stage} stage-#{stage}-#{submission.status_for_visible_stage(stage)}"
        list_class << " stage-#{stage}-current" if stage == submission.visible_stage
        list << content_tag(:li,
          link_to("Stage #{stage}: #{submission.status_for_visible_stage(stage)}", 
            "#TB_inline?height=400&width=320&inlineId=progress_explanation",
            :title => Submission::Stages[stage],
            :class => 'thickbox'),
          :class => list_class
        )
      end
      
      list
    end
  end
  
end