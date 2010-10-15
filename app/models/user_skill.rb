class UserSkill < ActiveRecord::Base
  belongs_to :user
  belongs_to :skill, :counter_cache => :users_count
  
  validates_uniqueness_of :skill_id, :scope => :user_id, :message => 'can only be used once per user'
  validates_presence_of :skill_title
  validates_presence_of :user_id

  attr_accessor :skill_title
  
  def skill_title=(skill_title)
    @skill_title = skill_title
    self.skill = Skill.find_or_create_by_title(skill_title)
  end

end