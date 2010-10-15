class Admin::FiltersController < Admin::AdminController
  before_filter :find_lps
  
  def index
    @filters = @lps.filters.all
  end
  
  def create
    @filter = ::Filter.build_filter_type(params[:filter])
    @filter.live_product_search = @lps
    if @filter.save
      flash[:notice] = 'The filter was successfully created'
    else
      flash[:error] = "Error creating filter: #{@filter.errors.full_messages.to_sentence}"
    end
    redirect_to admin_live_product_search_filters_path(@lps)
  end
  
  def destroy
    @filter = @lps.filters.find(params[:id])
    @filter.destroy
    flash[:notice] = 'The filter has been successfully destroyed'
    redirect_to admin_live_product_search_filters_path(@lps)
  end
  
  protected
    def find_lps
      @lps = LPS.find_by_key!(params[:live_product_search_id])
    end
end
