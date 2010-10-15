class IdeasController < ApplicationController
  ssl_required :show, :new, :create, :edit, :intellectual_property, :update
  
  before_filter :capture_coupon
  before_filter :login_required
  before_filter :find_user
  before_filter :find_idea, :only => [:show, :edit, :intellectual_property, :submit, :update, :destroy]
  before_filter :find_lps, :except => [:show, :submit]
  
  def show
    @submissions = @idea.submissions.complete.paginate(:page => params[:page], :per_page => App.per_page[:submissions])
  end
  
  def new
   # if @lps.member_search && !@user.member
   #   flash['notice'] = 'This search is for Insiders Only'
   #   redirect_to dashboard_path
   # else
      @idea = @user.ideas.new
    #end
  end
  
  def create
    @idea = @user.ideas.new(params[:idea])
    
    if @idea.save
      if params[:commit] == 'Save for Later'
        flash[:notice] = Idea::UpdatedMessage
        redirect_to ideas_dashboard_path
      else
        target =  @lps ?
          intellectual_property_live_product_search_idea_path(@lps, @idea) :
          intellectual_property_idea_path(@idea)
        redirect_to target
      end
    else
      render :new
    end
  end
  
  def edit
  end
  
  def intellectual_property
  end
  
  def submit
    redirect_to ideas_dashboard_path unless @idea.complete?
    @live_product_searches = LPS.current.all - @idea.live_product_searches.all
  end
  
  def update
    if @idea.update_attributes(params[:idea])
      @idea.ip_complete! if params[:intellectual_property]
      @idea.complete! if params[:attachments]
      flash[:notice] = Idea::UpdatedMessage if params[:commit] == 'Save for Later'
      
      target =  if params[:commit] == 'Save for Later'
                  ideas_dashboard_path
                elsif params[:intellectual_property]
                  @lps ? live_product_search_idea_attachments_path(@lps,@idea) : idea_attachments_path(@idea)
                elsif params[:attachments] # Last step of the idea creation process
                  @lps ? edit_live_product_search_idea_submission_path(@lps,@idea) : submit_idea_path(@idea)
                else
                  @lps ? intellectual_property_live_product_search_idea_path(@lps,@idea) : intellectual_property_idea_path(@idea)
                end
      
      redirect_to target
    else
      params[:intellectual_property] ? render(:intellectual_property) : render(:edit)
    end
  end
  
  def destroy
    if @idea.destroy
      flash[:notice] = Idea::DeletedMessage
    else
      flash[:error] = 'There was an error removing your idea. Please try again.'
    end
    redirect_to ideas_dashboard_path
  end
  
  protected
  
    def find_user
      @user = current_user
    end
    
    def find_idea
      @idea = @user.ideas.find(params[:id])
    end
    
    def find_lps
      @lps = LPS.find_by_key!(params[:live_product_search_id]) if params[:live_product_search_id]
    end
  
end
