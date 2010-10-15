class Admin::ForumsController < Admin::AdminController
  before_filter :find_forum, :only => [:show, :edit, :update]
  
  def index
    @forums = Forum.main.positioned.all
  end
  
  def show
    @topics = @forum.topics.ordered.paginate(:page => params[:page], :per_page => App.admin_per_page[:topics])
  end
  
  def edit
  end
  
  def update
    if @forum.update_attributes(params[:forum])
      flash[:notice] = 'The forum was successfully updated'
      redirect_to admin_forums_path
    else
      render :edit, :status => :bad_request      
    end
  end
  
  protected
    def find_forum
      @forum = Forum.find_by_url!(params[:id])
    end
  
end
