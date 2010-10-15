class Filter < ActiveRecord::Base
  
  belongs_to :live_product_search
  validates_presence_of :live_product_search, :stage
  
  before_validation_on_create :set_stage
  
  def self.build_filter_type(attributes = {})
    begin
      klass = attributes[:type] && attributes[:type].constantize
      klass ? klass.new(attributes) : new(attributes)
    rescue NameError
      new(attributes)
    end
  end
  
  protected
    class_inheritable_accessor :filter_stage
    def self.stage(s)
      self.filter_stage = s
    end
    
    def set_stage
      self.stage ||= self.class.filter_stage
    end
end

# PrototypeFilter
# passes if the idea has or doesn't have a prototype
class PrototypeFilter < Filter
  stage 2
  
  def pass?(submission)
    idea = submission.idea
    self.prototype_exists? ? idea.prototype? : !idea.prototype?
  end
  
end


# PatentFilter
# passes depending on whether an idea has a patent
# if the patent is issued or pending
# and/or what type of patent it is
class PatentFilter < Filter
  stage 3
  
  def pass?(submission)
    idea = submission.idea
    
    passed = self.patent_exists? ? idea.patents.any? : idea.patents.none?
    
    if self.patent_exists?
      if passed && self.patent_stage
        passed = idea.patents.any? {|p| p.stage == self.patent_stage}
      end
      
      if passed && self.patent_type
        passed = idea.patents.any? {|p| p.patent_type == self.patent_type}
      end
    end
    
    passed
  end
  
end

# QuestionFilter
# passes based on the users answer to a particular question
# can check that the answer IS, CONTAINS, or Includes a certain value
# as well as whether they answered true/false to a boolean question
class QuestionFilter < Filter
  stage 2
  
  Operators = {
    :is       => 'IS',
    :contains => 'CONTAINS',
    :includes => 'INCLUDES',
    :is_true  => 'IS TRUE',
    :is_false => 'IS FALSE'
  }
  
  belongs_to :question
  belongs_to :question_choice
  validates_presence_of :question, :question_operator
  validates_presence_of :question_value,  :if => :value_needed?
  validates_presence_of :question_choice, :if => :choices?
  
  def pass?(submission)
    answer = submission.answer_for(self.question)
    case question_operator
    when Operators[:is]
      question_value.downcase == answer.value.downcase
    when Operators[:contains]
      answer.value.to_s.downcase.match(question_value.to_s.downcase)
    when Operators[:includes]
      answer.choices.include?(question_choice)
    when Operators[:is_true]
      answer.value == true.to_s
    when Operators[:is_false]
      answer.value.blank? || answer.value == false.to_s
    else
      true # Broken filter
    end
  end
  
  def choices?
    question_operator == Operators[:includes]
  end
  
  def value_needed?
    [Operators[:is],Operators[:contains]].include? question_operator
  end
  
  def self.question_operator_options_for_question_type(qt)
    case qt
    when Question::Types[:true_false]
      [QuestionFilter::Operators[:is_true], QuestionFilter::Operators[:is_false]]
    when Question::Types[:short_answer]
      [QuestionFilter::Operators[:is], QuestionFilter::Operators[:contains]]
    when Question::Types[:essay]
      [QuestionFilter::Operators[:contains]]
    when Question::Types[:multiple_answer]
      [QuestionFilter::Operators[:includes]]
    when Question::Types[:single_answer]
      [QuestionFilter::Operators[:is]]
    end
  end
end

Filter::Types = {
  :prototype  => PrototypeFilter,
  :patent     => PatentFilter,
  :question   => QuestionFilter
}