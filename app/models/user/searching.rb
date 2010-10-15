class User
  
  # Thinking Sphinx indexes
  define_index do
    # fields
    indexes [:first_name, :last_name], :as => :name, :sortable => true
    indexes :login, :sortable => true
    indexes :email
    
    # attributes
    has created_at
    has admin
    has active
  end
  
end