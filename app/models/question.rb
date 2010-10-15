class Question < ActiveRecord::Base
  Types = {
    :true_false       => 'true/false',
    :short_answer     => 'short answer',
    :essay            => 'essay',
    :multiple_answer  => 'multiple answer',
    :single_answer    => 'single answer',
    :date             => 'date'
  }
  
  belongs_to :live_product_search
  
  has_many :answers, :dependent => :destroy
  
  has_many :choices, :class_name => 'QuestionChoice', :dependent => :destroy
  accepts_nested_attributes_for :choices, :allow_destroy => true, :reject_if => proc{|attrs| attrs.values.all?(&:blank?)}
  
  validates_presence_of :live_product_search_id, :label, :question_type
  
  attr_protected :live_product_search_id
  
end
