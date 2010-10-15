class Badge < ActiveRecord::Base
  include Comparable
  
  has_attached_file :image,
                    :styles => {
                                 :large => "200x23>",
                                 :thumb => "100x18>"
                               },
                    :default_url => ""
                    
  has_and_belongs_to_many :users, :join_table => 'users_badges'
  
  validates_presence_of :name
  validates_attachment_presence :image
  
  def <=>(other_badge)
    weight <=> other_badge.weight
  end
  
end
