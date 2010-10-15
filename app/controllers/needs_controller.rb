class NeedsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :find_need, :only => :show
  before_filter :viewable_by_current_user_check, :only => :show
  before_filter :find_popular_tags, :only => [:index, :show]
  
  def index
    @needs = params[:q] ? Need.search(params[:q], :per_page => App.per_page[:needs], :page => params[:page]) : 
                          Need.paginate(:all, :include => :tags, :order => 'created_at DESC', :per_page => App.per_page[:needs], :page => params[:page])
  end
  
  def show
  end
  
  def new
    @need = current_user.needs.new
    respond_to do |format|
      format.html
      format.js do 
        @tag = Tag.new
        render :layout => false
      end
    end
  end
  
  def create
    @need = current_user.needs.new(params[:need])
    if @need.save
      flash[:notice] = "Your need was added successfully."
      redirect_to needs_path
    else
      render :action => :new
    end
  end

  protected
    def find_need
      @need = Need.find_by_url!(params[:id])
    end
    
    def find_popular_tags
      @popular_need_tags = Tag.popular_need_tags
    end
    
    def viewable_by_current_user_check
      viewable = @need.user.needs_viewable_by?(current_user)
      unless viewable
        flash[:error] = "You are not authorized to view needs added by #{@need.user.login}."
        redirect_to needs_path
      end
      return viewable
    end
end
