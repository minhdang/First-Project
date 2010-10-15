class BlogEntry < ActiveRecord::Base
  
  belongs_to :bloggable, :polymorphic => true
  
  validates_presence_of :title, :body
  
  formats_attributes :body

  acts_as_url :title
  
  named_scope :limited, lambda { |limit| { :limit => limit }}  
  named_scope :ordered, lambda { |order| { :order => order }}
  
  def to_param
    url
  end
end
