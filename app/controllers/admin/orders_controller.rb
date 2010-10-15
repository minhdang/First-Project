class Admin::OrdersController < Admin::AdminController
  before_filter :redirect_to_show_when_order_number_provided, :only => :index
  before_filter :find_order, :only => [:show, :update, :edit]
  
  role_required [:fulfillment_provider, :store_admin, :superuser], :index, :show, :update

  def index
    @scope  = Order.scopes.keys.include?(params[:scope] && params[:scope].to_sym) && params[:scope].to_sym
    scoped  = @scope ? Order.send(@scope) : Order
    respond_to do |format|
      format.html do
        @orders = scoped.paginate(:include => [:user, :order_items], :per_page => App.admin_per_page[:orders], :page => params[:page])      
      end
      format.txt { render :text => Order.search(params[:q]).collect(&:number).join("\n") }
      format.csv { @orders = scoped.all }
    end
  end

  def show
  end
  
  def edit
  end

  def update
    unless @order.shipped?
      if (params[:order][:carrier] && params[:order][:tracking_number])
        @order.ship_via(params[:order][:carrier], params[:order][:tracking_number])
        flash[:notice] = "The order has been marked as shipped."
        redirect_to admin_order_path(@order)
      end
    end
    
    if @order.unpaid?
      if @order.update_attributes(params[:order]) && @order.pay!
        flash[:notice] = "The payment has been received successfully"
        redirect_to admin_order_path(@order)
      else
        render :edit
      end
    end
  end

  protected
  def redirect_to_show_when_order_number_provided
    if params[:order_number]
      redirect_to admin_order_path(:id => params[:order_number])
    end
  end
  
  def find_order
    @order = Order.find_by_number!(params[:id])
  end
end