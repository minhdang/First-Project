class PatentsController < ApplicationController
  before_filter :login_required
  before_filter :find_idea
  before_filter :find_patent
  
  def show
    if @patent.application?
      redirect_to @patent.application.temporary_url
    else
      render :nothing => true
    end
  end
  
  protected
    
    def find_idea
      @idea = current_user.ideas.find(params[:idea_id])
    end
    
    def find_patent
      @patent = @idea.patents.find(params[:id])
    end
end
