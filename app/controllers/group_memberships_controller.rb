class GroupMembershipsController < ApplicationController
  before_filter :login_required, :except => :index
  before_filter :find_group_and_ensure_no_membership, :only => :create
  before_filter :find_group_membership, :except => [:index, :create]
  before_filter :ensure_group_owner, :only => :update
  before_filter :ensure_owner_or_group_owner, :only => :destroy
  
  def index
    @group = Group.find_by_url!(params[:group_id])
    @group_memberships = @group.group_memberships.active.paginate(:page => params[:page], :per_page => App.per_page[:users])
    @pending_group_memberships = @group.group_memberships.pending.all if logged_in? && current_user == @group.owner
  end
  
  def create
    if current_user.join_group(@group)
      if @group.private?
        flash[:notice] = "This group is private. A notice has been sent to the owner of this group to review your membership."
      else
        flash[:notice] = "Congratulations, you are now a member of the '#{@group.title}' group."
      end
    else
      flash[:error] = 'There was a problem joining the group. Please try again.'
    end
    redirect_to group_path(@group)
  end
  
  def update    
    case params[:decision].to_sym
    when :activate
      @group_membership.activate! if @group_membership.pending?
      flash[:notice] = "#{@group_membership.user.login} is now a member of your group"
    when :deny
      @group_membership.deny! if @group_membership.pending?
    end
    redirect_to group_members_path(@group_membership.group)
  end
  
  def destroy
    if current_user == @group_membership.user
      @group_membership.destroy
      flash[:notice] = "You are no longer a member of the '#{@group_membership.group.title}' group."
    elsif current_user == @group_membership.group.owner
      @group_membership.destroy
      flash[:notice] = "#{@group_membership.user.login} is no longer a member of this group."
    end
    redirect_to group_members_path(@group_membership.group)
  end
  
  protected
    
    def find_group_and_ensure_no_membership
      @group = Group.find_by_url!(params[:group])
      membership = current_user.group_memberships.find(:first, :conditions => ["group_id = ? && (state = 'active' || state = 'pending')", @group.id])
      if membership
        flash[:notice] = "You already have a #{membership.state} membership with this group"
        redirect_to group_members_path(@group)
      end
      !membership
    end
    
    def find_group_membership
      @group_membership = GroupMembership.find(params[:id])
    end
    
    def ensure_group_owner
      group_owner = current_user == @group_membership.group.owner
      unless group_owner
        flash[:error] = "You are not authorized to modify this group's memberships."
        redirect_to group_path(@group_membership.group)
      end
      group_owner
    end
    
    def ensure_owner_or_group_owner
      owner_or_group_owner = current_user == @group_membership.user || current_user == @group_membership.group.owner
      unless owner_or_group_owner
        flash[:error] = "You are not authorized to modify this group's memberships."
        redirect_to group_path(@group_membership.group)
      end
      owner_or_group_owner
    end
end
