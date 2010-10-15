class IssuesController < ApplicationController
  before_filter :login_required, :except => [:atom_feed]
  before_filter :membership_required, :except => [:atom_feed]
  
  def index    
    @issues = Issue.active.find(:all, :order => 'published_at DESC')
  end
  
  def show
    @issue = Issue.find(params[:id])
  end

  def atom_feed
    @issues = Issue.active.find(:all, :order => 'published_at DESC')
    respond_to do |format|
      format.xml
    end
  end

  protected
    def membership_required_notice
      "You must be an Edison Insider to view the Inventors Digest archive. " +
      "Check out the many other Edison Insider benefits below."
    end
end