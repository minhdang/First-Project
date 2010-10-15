class ForumsController < ApplicationController
  before_filter :show_topics_if_preferred, :unless => :forced?, :only => :index
  
  caches_action :index, :cache_path => Proc.new {|c| c.send(:cache_path)}
  caches_action :show,  :cache_path => Proc.new {|c| c.send(:cache_path)}, :unless => :flash_message?
  
  # GET /forums
  # GET /forums.xml
  def index
    # reset the page of each forum we have visited when we go back to index
    session[:forums_page] = nil

    @forums = Forum.main.positioned.find(:all, :include => {:recent_topic => {:last_post => :user}})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forums }
    end
  end

  # GET /forums/1
  # GET /forums/1.xml
  def show
    @forum = Forum.main.find_by_url!(params[:id])
    (session[:forums] ||= {})[@forum.id] = Time.now.utc
    (session[:forums_page] ||= Hash.new(1))[@forum.id] = current_page if current_page > 1

    respond_to do |format|
      format.html do # show.html.erb
        @topics = @forum.topics.active.paginate(:page => current_page, :per_page => per_page)
      end
      format.xml  { render :xml => @forum }
    end
  end
  
  protected
    
    def show_topics_if_preferred
      prefers_topics = user_preferences.forums_view_mode == 'topics'
      if prefers_topics
        redirect_to topics_path
      end
      !prefers_topics
    end
    
    def forced?
      params[:force]
    end
    
    # Auto expiring cache path based on the most recently updated post in the system
    # May get some unnecessary cache misses due to posts being updated in group forums
    # that don't affect the main forums but it serves its purpose
    def cache_path
      "forums/#{params[:id]}?page=#{current_page}" +
      "#{ if action_name == 'show' then "&per_page="+per_page.to_s end }" +
      "##{Post.recently_updated.first.updated_at.to_i}"
    end
end