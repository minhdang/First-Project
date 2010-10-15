class Admin::CouponsController < Admin::AdminController
  
  before_filter :find_coupon, :only => [:show, :edit, :update, :destroy]
  
  role_required [:store_admin, :superuser], :index, :show, :new, :edit, :create, :update, :destroy
  
  def index
    @coupons = Coupon.all
  end
  
  def show
  end
  
  def new
    @coupon = Coupon.new
  end
  
  def edit
  end
  
  def create
    @coupon = Coupon.new(params[:coupon])
    
    if @coupon.save
      flash[:notice] = "The coupon '#{@coupon.code}' was created successfully and is ready for use"
      redirect_to admin_coupons_path
    else
      render :new
    end
  end
  
  def update
    if @coupon.update_attributes(params[:coupon])
      flash[:notice] = "The coupon '#{@coupon.code}' was updated successfully"
      redirect_to admin_coupons_path
    else
      render :edit
    end
  end
  
  def destroy
    @coupon.destroy
    flash[:notice] = "The coupon '#{@coupon.code}' was destroyed successfully"
    redirect_to admin_coupons_path
  end
  
  protected
    
    def find_coupon
      @coupon = Coupon.find_by_url!(params[:id])
    end
  
end
