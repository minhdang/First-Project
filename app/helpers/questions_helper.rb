module QuestionsHelper
  
  def answer_input_field(f, answer)
    case answer.question.question_type
    when Question::Types[:true_false]
      f.check_box(:value, {}, 'true', 'false')
    when Question::Types[:short_answer]
      f.text_field(:value)
    when Question::Types[:essay]
      f.text_area(:value, :class => 'full short')
    when Question::Types[:multiple_answer]
      f.fields_for :choice_ids do |boxes|
        choices = ''
        answer.question.choices.each_with_index do |c,i|
          id = sanitize_to_id("#{boxes.object_name}_#{i}")
          choices << check_box_tag("#{boxes.object_name}[]", c.id, answer.choices.include?(c), :id => id)
          choices << label_tag("#{boxes.object_name}", c.label, :class => 'inline', :for => id)
          choices << "<br/>"
        end
        choices
      end
    when Question::Types[:single_answer]
      f.select :value, answer.question.choices.map(&:label), :prompt => '-- Select --'
    when Question::Types[:date]
      f.text_field :value, :class => 'calendar'
    else
      'unknown'
    end
  end
  
end