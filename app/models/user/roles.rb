class User
  
  has_and_belongs_to_many :roles, :join_table => "users_roles"
  
  def has_role?(*roles)
    roles.any? do |role|
      role = role.kind_of?(Role) ? role : Role.find_by_name(role.to_s)
      self.roles.include?(role)
    end
  end
end