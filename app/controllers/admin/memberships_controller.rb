class Admin::MembershipsController < Admin::AdminController
  
  before_filter :find_user, :only => [:new, :edit, :update, :create, :show]
  before_filter :find_membership, :except => [:index, :new, :create]
  before_filter :ensure_not_member, :only => [:new, :create]
  
  role_required :staff, :index, :show
  role_required :superuser, :new, :edit, :create, :update, :destroy
  
  def index
    @scope = params[:scope] && Membership.scopes.keys.include?(params[:scope].to_sym) ?
             params[:scope].to_sym :
             :current
    @memberships = Membership.send(@scope).paginate(:include => :user, :page => params[:page], :per_page => App.admin_per_page[:memberships])
  end
  
  def show
  end
  
  def new
    @membership = Membership.new
    @membership.build_payment
    @membership.payment.build_billing_address
  end
  
  def edit
  end
  
  def create
    @membership         = Membership.new(params[:membership])
    @membership.user    = @user
    @membership.cost    = params[:membership][:cost]
    
    if @membership.save
      if @membership.activate!
        flash[:notice] = "#{@user.login} is now an Edison Insider."
        redirect_to admin_user_membership_path(@user)
      else
        render :action => :edit
      end
    else
      unless @membership.payment
        @membership.build_payment
        @membership.payment.build_billing_address
      end
      render :action => :new
    end
  end
  
  def update
    if @membership.update_attributes(params[:membership]) && @membership.activate!
      flash[:notice] = "#{@user.login} is now an Edison Insider."
      redirect_to admin_user_membership_path(@user)
    else
      render :action => :edit
    end
  end
  
  # Cancel this users membership
  def destroy
    @membership.cancel!
    flash[:notice] = "#{@membership.user.login}'s membership has been canceled. They will be notified via email."
    redirect_to admin_membership_path(@membership)
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id]) if params[:user_id]
    end
    
    def find_membership
      @membership = @user ? @user.membership : Membership.find(params[:id])
    end
    
    def ensure_not_member
      if @user.member?
        flash[:error] = 'This user already has a membership.'
        redirect_to admin_user_membership_path(@user)
      end
      !@user.member?
    end
end
