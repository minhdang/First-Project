class CampusesController < ApplicationController
  before_filter :find_popular_campuses, :only => [:index, :show]

  def index  
    @campuses = params[:q] ? 
      Campus.search(params[:q]).paginate({:per_page => App.per_page[:campuses], :page => params[:page]}) :
      Campus.find(:all, :order => 'created_at DESC', :limit => App.newest[:campuses])
    
    respond_to do |format|
      format.html { }
      format.txt { render :text => @campuses.map(&:title).join("\n") }
    end
  end

  def show
    @campus = Campus.find_by_url!(params[:id], :include => :users)
    @users = @campus.users.reject {|user| !user.education_public }.paginate(:per_page => App.per_page[:campus_users], :page => params[:page])
  end

  protected
    def find_popular_campuses
      @popular_campuses = Campus.find_popular
    end
end
