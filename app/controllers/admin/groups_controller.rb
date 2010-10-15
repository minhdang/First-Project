class Admin::GroupsController < Admin::AdminController
  
  before_filter :find_group, :only => [:show, :edit, :update, :destroy]
  
  role_required :staff, :index, :show, :new, :edit, :create, :update, :destroy
  
  def index
    @groups = Group.paginate(:page => params[:page], :per_page => App.admin_per_page[:groups])
  end
  
  def show
  end
  
  def new
    @group = Group.new
  end
  
  def edit
  end
  
  def create
    @group = Group.new(params[:group])
    @group.owner = current_user
    
    if @group.save
      flash[:notice] = "'#{h @group.title}' group created successfully"
      redirect_to admin_group_path(@group)
    else
      render :action => :new
    end
  end
  
  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = "'#{h @group.title}' group updated successfully"
      redirect_to admin_group_path(@group)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @group.destroy
      flash[:notice] = "'#{h @group.title}' group deleted successfully"
    else
      flash[:error] = "There was a problem deleting the group. Please try again."
    end
    redirect_to admin_groups_path
  end
  
  protected
    def find_group
      @group = Group.find_by_url!(params[:id])
    end
  
end
