class Admin::RolesController < Admin::AdminController
  role_required :superuser, :index, :show, :new, :edit, :create, :update, :destroy
  before_filter :find_role, :only => [:show, :edit, :update, :destroy]
  
  def index
    @roles = Role.all
  end
  
  def show
    @users = @role.users.paginate(:page => params[:page], :per_page => App.admin_per_page[:users])
  end
  
  def new
    @role = Role.new
  end
  
  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "The role has been added successfully"
      redirect_to admin_roles_path
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @role.update_attributes(params[:role])
      flash[:notice] = "The role has been updated successfully"
      redirect_to admin_role_path(@role)
    else
      render :edit
    end
  end
  
  def destroy
    @role.destroy
    flash[:notice] = 'The role has been destroyed successfully'
    redirect_to admin_roles_path
  end
  
  protected
    def find_role
      @role = Role.find_by_url!(params[:id])
    end
  
end
