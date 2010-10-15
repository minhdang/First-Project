class Admin::UsersController < Admin::AdminController
  before_filter :find_user, :except => :index
  
  role_required :staff, :index, :show
  role_required :superuser, :edit, :update
  role_required :fulfillment_provider, :show
  
  def index
    @scope = params[:scope] && User.scopes.keys.include?(params[:scope].to_sym) ?
             params[:scope].to_sym :
             :all
    @users =  if params[:q]
                User.search(params[:q], :page => params[:page], :per_page => App.admin_per_page[:users])
              else
                @scoped = User.newest_first
                @scoped = @scoped.send(@scope) unless @scope == :all
                @scoped.paginate :page => params[:page], :per_page => App.admin_per_page[:users]
              end
    
    respond_to do |format|
      format.html
      format.txt  { render :text => @users.map(&:name).join("\n") }
      format.csv
    end
  end
  
  def show
    @logins = @user.logins.last_ten
  end
  
  def edit
  end
  
  def update
    # set protected attributes
    @user.editing_in_admin = true
    @user.moderator = params[:user][:moderator]
    @user.admin = params[:user][:admin]
    @user.move_to_state(params[:user][:state]) unless params[:user][:state].blank?
    @user.badge_ids = params[:user][:badge_ids] if params[:user][:badge_ids]
    @user.current_badge_id = params[:user][:current_badge_id].to_i if params[:user][:current_badge_id]
    @user.current_badge_id = nil if @user.current_badge_id == 0
    @user.role_ids = params[:user][:role_ids] if params[:user][:role_ids]
    @user.email = params[:user][:email] if params[:user][:email]
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "User #{@user.login}'s information updated successfully."
      redirect_to admin_user_path(@user)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @user.send_later(:delete!)
      flash[:notice] = "The account has been queued for deletion."
      redirect_to admin_user_path(@user)
    end
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:id])
    end
end