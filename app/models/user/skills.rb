class User
  has_many :user_skills, :dependent => :destroy
  has_many :skills, :through => :user_skills

  def has_skill?(skill)
    skills.include?(skill)
  end
end