class Admin::LiveProductSearchesController < Admin::AdminController
  role_required [:lps_judge, :lps_commentator], :index, :show
  role_required [:superuser, :lps_admin], :index, :show, :new, :edit, :create, :update, :destroy
  
  before_filter :find_lps, :only => [:show, :edit, :update, :destroy]
  
  def index
    @scope = params[:scope] && LPS.scopes.keys.include?(params[:scope].to_sym) ?
             params[:scope].to_sym :
             :published
    
    @live_product_searches = LPS.send(@scope).paginate(
      {:page => params[:page], :per_page => App.admin_per_page[:live_product_searches]}
    )
  end
  
  def show
  end
  
  def new
    @lps = LPS.new
  end
  
  def edit
  end
  
  def create
    @lps = LPS.new(params[:live_product_search])
    @lps.move_to_state(params[:live_product_search][:state]) if params[:live_product_search][:state]
    
    if @lps.save
      flash[:notice] = "LPS '#{@lps.title}' was created successfully"
      redirect_to admin_live_product_search_questions_path(@lps)
    else
      render :new
    end
  end
  
  def update
    @lps.move_to_state(params[:live_product_search][:state]) if params[:live_product_search][:state]
    if @lps.update_attributes(params[:live_product_search])
      flash[:notice] = "LPS '#{@lps.title}' was updated successfully"
      redirect_to admin_live_product_searches_path
    else
      render :edit
    end
  end
  
  def destroy
    @lps.delete!
    flash[:notice] = "LPS '#{@lps.title}' was successfully marked as deleted but will remain in the database"
    redirect_to admin_live_product_searches_path
  end
  
  protected
    
    def find_lps
      @lps = LPS.find_by_key!(params[:id])
    end
end
