class IdeaCategory < ActiveRecord::Base
  
  has_many :ideas, :foreign_key => 'category_id'
  
  validates_uniqueness_of :name
  
  default_scope :order => 'name ASC'
  
  # Alphabetically Sorted with 'Other' always at the bottom
  def <=>(other_category)
    if name == 'Other'
      1
    elsif other_category.name == 'Other'
      -1
    else
      name <=> other_category.name
    end
  end
  
end
