module UsersHelper
  
  def prefer_avatars(users, limit=16)
    users = users.limited(limit*4) if users.class == ActiveRecord::NamedScope::Scope
    
    users_with_avatars, users_without_avatars = users.partition(&:avatar?).map(&:shuffle)
    sorted = users_with_avatars + users_without_avatars
    sorted[0...limit].shuffle
  end
  
  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={})
    raise "Invalid user" unless user
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    link_to h(content_text), user_path(user), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address 
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_user
      [:content_method, :title_method].each{|opt| options.delete(opt)} 
      link_to_login_with_IP content_text, options
    end
  end
  
  #
  # Displays the users avatar along with an account badge.
  # This avarar is linked to the users profile page.
  # Style is a symbol that matches the paperclip style of the
  # avatar. Valid options :original, :large, :thumb
  #
  def badge_for(user, style = :thumb)
    if user
    content_tag :div, :class => 'user-badge' do
      content  = link_to(avatar(user, style), user_path(user))
      content += image_tag(user.current_badge.image.url(style), :class => 'badge-label', :alt => user.current_badge.name) if user.current_badge
      concat content
    end
  end
  end
  
  def avatar(user, style = :thumb)
    if user
      image_tag(user.avatar.url(style), :alt => "#{user.login}'s Avatar", :class => 'avatar')
    end
  end
  
  def privacy_options
    [["Friends", false], ["Public", true]]
  end
  
  # your, his, her, their
  def possessive(user)
    return 'your' if (user == current_user)
    return 'their' unless user.contact_information && user.contact_information.gender
    user.contact_information.gender == 'male' ? 'his' : 'her'
  end
  
  def email_link(user)
    link_text = "Click here to email #{user.first_name}"
    if user.login == 'enteam'
      mail_to user.email, link_text, :class => 'send-email'
    else
      link_to link_text, new_user_message_path(user), :class => 'send-email'
    end
  end
  
  def display_user_resource_if_viewable(user, resource, options={})
    options.reverse_merge!({:partial => resource.to_s})
    
    if user.resource_viewable_by?(current_user, resource)
      render :partial => "users/resources/#{options[:partial]}", :locals => {:user => user}
    end
  end
  
  def user_actions(user)
    content = admin_update_account_state_link(user)
    content += link_to "edit user", edit_admin_user_path(@user), :class => 'action'
    content += admin_update_user_membership_link(user)
  end
  
  def admin_update_user_membership_link(user)
    if user.member?
      link_to "Cancel Membership", admin_membership_path(@user.membership), 
        :confirm => "Are you sure? The user will be notified via email that their Edison Insider membership has been canceled.", 
        :class => 'action', 
        :method => 'delete'
    else
      link_to "Create Membership", new_admin_user_membership_path(@user), :class => 'action'
    end    
  end
  
  def admin_update_account_state_link(user)
    if user.deleted?
      link_to "activate user", admin_user_path(@user, {:user => {:state => 'active'}}), 
        :method => :put, 
        :class => 'action'
    else
      link_to "delete user", admin_user_path(@user),  
        :method => :delete, 
        :confirm => "Are you sure? The user will remain in the database with a status of 'deleted'.", 
        :class => 'action'
    end
  end
end