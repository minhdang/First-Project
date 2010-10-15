class TopicsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :destroy]
  before_filter :find_forum, :except => [:index, :new]
  before_filter :find_topic, :only => [:show, :destroy]

  before_filter :current_user_sees_topic, :if => :logged_in?, :only => :show
  before_filter :increment_topic_hits_counter, :only => :show

  before_filter :require_forum_is_editable_by_user, :only => :create
  
  before_filter :restricted_roles
  
  caches_action :index, :cache_path => Proc.new { |controller| controller.send(:index_cache_path) }, :unless => :flash_message?
  caches_action :show, :cache_path => Proc.new { |controller| controller.send(:show_cache_path) }, :unless => :flash_message?

  def index
    @topics = Topic.main.active.ordered.paginate(:page => current_page, :per_page => per_page, :include => :last_user)
    
    respond_to do |format|
      format.html
      format.xml  {render :xml  => @topics}
    end
  end

  def show
    respond_to do |format|
      format.html do
          set_page_to_last if current_page == :last
          set_page_to_max  if current_page > maximum_pages
        
          @first_post = @topic.first_post
          @posts = @topic.replies.active.paginate :include => :user, :order => "posts.created_at #{posts_order}", :page => current_page, :per_page => per_page
          @post  = Post.new
      end
      format.xml  { render :xml  => @topic }
    end
  end

  def new
    @forum          = Forum.find_by_url(params[:forum_id])
    @forum_editable = require_forum_is_editable_by_user if @forum
    return if @forum && !@forum_editable
    
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @topic }
    end
  end

  def create
    @topic = current_user.post_to_forum @forum, params[:topic]

    respond_to do |format|
      if @topic.new_record?
        format.html { render :action => "new" }
        format.xml  { render :xml  => @topic.errors, :status => :unprocessable_entity }
      else
        format.html { redirect_to(forum_topic_path(@forum, @topic)) }
        format.xml  { render :xml  => @topic, :status => :created, :location => forum_topic_url(@forum, @topic) }
      end
    end
  end

protected
  def find_forum
    @forum = if params[:forum_id]
      Forum.find_by_url!(params[:forum_id])
    else
      forum_id = params[:topic] ? params[:topic][:forum_id] : nil
      Forum.find(forum_id)
    end
  end
  
  def find_topic
    @topic = @forum.topics.active.find_by_url!(params[:id])
  end
  
  # Ensure that the user is allowed to create a topic 
  # for the current forum
  def require_forum_is_editable_by_user
    editable = @forum.editable_by?(current_user)
    unless editable
      flash[:error] = 'You do not have permission to edit this forum.'
      redirect_to_referer
    end
    editable
  end
  
  # log when the current user seea the topic. Useful for showing 'X new topics' type features
  def current_user_sees_topic
    current_user.view_topic!(@topic)
    (session[:topics] ||= {})[@topic.id] = Time.now.utc
  end
  
  # Increment a counter that shows how many times a topic has been viewed
  # by people other then its creator
  def increment_topic_hits_counter
    @topic.hit! unless logged_in? && current_user.id == @topic.user_id
  end
  
  def posts_order
    user_preferences.posts_order
  end
  
  # Set the current page to the last page if page is sent as a param
  # and it is equal to 'last' ex. topics/?page=last
  # really only used for redirecting to the last page so users can see
  # the reply that they just posted.
  def set_page_to_last
    return @page = 1 if user_preferences.posts_order == 'DESC'
    last_page = (@topic.replies.count.to_f / per_page).ceil
    @page = last_page == 0 ? 1 : last_page
  end
  
  def maximum_pages
    max_page = (@topic.replies.count.to_f / per_page).ceil
    max_page == 0 ? 1 : max_page
  end
  
  def set_page_to_max
    @page = maximum_pages
  end
  
  # Seperate caches for this forum from others
  # this way topics with the same permalinks in
  # different forums won't have the same caches
  def show_cache_path
    "forums/#{@forum.id}/topics/#{@topic.id}?page=#{current_page}" +
    "&per_page=#{per_page}&order=#{posts_order}&monitored=#{logged_in? && current_user.monitors_topic?(@topic)}" +
    "##{@topic.fresh_post.updated_at.to_i}"
  end
  
  def index_cache_path
    "topics/?page=#{current_page}&per_page=#{per_page}" +
    "##{Post.recently_updated.first.updated_at.to_i}"
  end
  
  def restricted_roles
    if current_user && current_user.has_role?(:battelle)
      redirect_to dashboard_path
    end
  end
  
end
