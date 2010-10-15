class Admin::AdminController < ApplicationController
  layout 'admin'
  
  before_filter :login_required
  before_filter :admin_required
  before_filter :ensure_required_role
  
  protected
    def self.role_required(roles, *actions)
      roles = roles.kind_of?(Array) ? roles : [roles]
    
      roles.each do |role|
        write_inheritable_hash(:required_roles, {role => actions})
      end
    end
  
  private
    def admin_required
      is_admin = current_user && current_user.admin?
      unless is_admin
        flash[:notice] = "You are not authorized to view this page."
        redirect_to login_path
      end
      is_admin
    end
    
    def ssl_required?
      ['staging','production'].include?(Rails.env)
    end
    
    def ensure_required_role
      required_roles = self.class.read_inheritable_attribute(:required_roles) || {}
      
      required_roles.each do |role, actions|
        @has_required_role ||= current_user.has_role?(role) if actions.include?(action_name.to_sym)
      end
      @has_required_role = @has_required_role.nil? ? true : @has_required_role
      
      unless @has_required_role
        flash[:error] = "You do not have sufficient privileges to access that page. One of the following roles is required: " +
                        required_roles.stringify_keys.keys.sort.map(&:titleize).to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
        redirect_to admin_dashboard_path
      end
      
      @has_require_role
    end
end