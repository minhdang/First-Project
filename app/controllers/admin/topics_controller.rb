class Admin::TopicsController < Admin::AdminController
  before_filter :find_topic, :only => [:show, :edit, :update]
  
  def index
    @topics = Topic.main.ordered.paginate(:page => params[:page], :per_page => App.admin_per_page[:topics])
  end
  
  def show
    @first_post = @topic.first_post
    @replies    = @topic.replies.paginate(
      {
        :page => params[:page], :per_page => App.admin_per_page[:posts],
        :order => 'posts.created_at DESC'
      })
  end
  
  def edit
  end
  
  def update
    @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    @topic.locked   = params[:topic][:locked] if params[:topic][:locked]
    
    if @topic.update_attributes(params[:topic])
      flash[:notice] = 'This topic was updated successfully'
      redirect_to admin_topic_path(@topic)
    else
      render :edit, :status => :bad_request
    end
  end
  
  protected
    
    def find_topic
      @topic = Topic.find_by_url!(params[:id])
    end
  
end
