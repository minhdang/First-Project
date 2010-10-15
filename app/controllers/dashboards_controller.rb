class DashboardsController < ApplicationController
  layout 'dashboard'
  
  before_filter :login_required, :except => [:public, :show, :preview]
  before_filter :find_user, :if => :logged_in?
  before_filter :display_public_dashboard, :unless => :logged_in?, :only => :show
  before_filter :get_notices, :except => [:public]
  
  def show
    @live_product_searches   = LPS.current
    @submissions = @user.submissions.complete.archived(false).limit(2).all(:include => [:live_product_search, :idea])
    @site_bulletins = SiteBulletin.current
  end
  
  def public
    render(:action => :public, :layout => 'application')
  end
  
  def live_product_search    
    @live_product_searches = LPS.current.all
  end
  
  def ideas
    @ideas = @user.ideas.paginate(:page => params[:page], :per_page => App.per_page[:ideas])
    @submissions = @user.submissions.complete.archived(false).limit(5).all(:include => [:live_product_search, :idea])
  end
  
  def survey
    @surveys = Survey.current
    @responses = @user.survey_responses.complete.paginate(:page => params[:page], :per_page => App.per_page[:responses])
  end
  
  def feedback
    @feedback = Submission.find(params[:id])
    respond_to do |format|
      format.js{}
    end
  end
  
  protected
    def get_notices
      @notices = @user.notices.limit(20)
    end
    
    def find_user
      @user = current_user
    end
  
    def display_public_dashboard
      render(:action => :public, :layout => 'application')
      return false
    end
  
end
