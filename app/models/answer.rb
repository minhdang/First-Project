class Answer < ActiveRecord::Base
  
  belongs_to :submission
  belongs_to :question
  
  has_and_belongs_to_many :choices, :class_name => 'QuestionChoice'
  accepts_nested_attributes_for :choices, :reject_if => proc{|attrs| attrs[:label].blank? }
  
  validates_presence_of :question_id
  validate  :valid_answer, :if => :required?
  
  serialize :value
  
  named_scope :for_question, lambda {|q|
    {:conditions => {:question_id => q.id}}
  }
  
  def required?
    question && question.required?
  end
  
  def value=(pre_cast)
    
    self[:value] = case question.question_type
    when Question::Types[:date]
      pre_cast.blank? ? nil : Date.parse(pre_cast)
    else
      pre_cast
    end
  end
  
  def value 
    case question.question_type
    when Question::Types[:multiple_answer]
      choices
    else
      self[:value]
    end
  end
  
  protected
  
    def valid_answer
      errors.add_to_base("You must answer: '#{question.label}'") if self[:value].blank? && choices.empty?
    end
  
end
