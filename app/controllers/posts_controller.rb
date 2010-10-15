class PostsController < ApplicationController
  before_filter :login_required, :except => :index
  before_filter :find_forum, :except => :index
  before_filter :find_topic, :except => :index
  before_filter :find_post, :only => [:edit, :update, :spam]
  before_filter :require_owner, :only => [:edit, :update]
  before_filter :require_post_still_editable, :only => [:edit, :update]
  before_filter :require_topic_postable_by_user, :only => :create
  
  protect_from_forgery :except => [:create, :spam]
  
  def index # Only used for showing searches
    @posts =  Post.search(params[:q], :conditions => {:state => 'active'}, :page => current_page, :per_page => 25)
  end
  
  def new
    @post = Post.new
  end
  
  def edit
  end
  
  def create
    @post = current_user.reply_to_topic(@topic, params[:post][:body])
    
    if @post.save
      redirect_to forum_topic_path(@forum, @topic, :page => 'last', :anchor => dom_id(@post))
    else
      render :action => :new
    end
  end
  
  def update
    post = current_user.revise(@post, params[:post])
    if post && post.errors.empty?
      redirect_to forum_topic_path(@forum, @topic, :page => 'last', :anchor => dom_id(@post))
    else
      render :action => :edit
    end
  end
  
  # incremement a spam counter for this post
  def spam
    @post.moderator = current_user if current_user.moderator?
    current_user.moderator? ? current_user.moderate!(@post) : @post.spam_hit!(current_user.moderator?)
    flash[:notice] = 'Thank you for notifying us of this issue. We will look into it shortly.'
    redirect_to @post.topic.active? ? forum_topic_path(@post.forum, @post.topic) : forums_path
  end
  
  protected
    def find_forum
      @forum = Forum.find_by_url!(params[:forum_id])
    end
    
    def find_topic
      @topic = @forum.topics.find_by_url!(params[:topic_id])
    end
    
    def find_post
      @post = @topic.posts.find(params[:id])
    end
    
    def require_owner
      owner = current_user == @post.user
      unless owner
        redirect_to forum_topic_path(@forum, @topic)
      end
      owner
    end
    
    def require_post_still_editable
      unless @post.created_at >= 30.minutes.ago
        flash[:notice] = "This post is too old to be edited and has become locked."
        redirect_to :back
      end
    end
    
    def require_topic_postable_by_user
      unless @topic.postable_by?(current_user)
        flash[:notice] = "You do not have permission to post to this topic."
        redirect_to :back
      end
    end
end
