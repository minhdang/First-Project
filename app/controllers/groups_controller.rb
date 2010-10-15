class GroupsController < ApplicationController
  include ActionView::Helpers::TagHelper
  
  before_filter :login_required, :only => [:new, :create]
  before_filter :find_group, :only => [:show, :edit, :update]
  before_filter :find_user, :only => :index
  
  def index
    @groups = if @user
                @user.groups.paginate(:page => params[:page], :per_page => App.per_page[:groups])
              elsif params[:q]
                Group.search(params[:q], :page => params[:page], :per_page => App.per_page[:groups])
              elsif params[:region]
                Group.paginate(:conditions => {:region => params[:region]}, :page => params[:page], :per_page => App.per_page[:groups])
              else
                Group.paginate(:page => params[:page], :per_page => App.per_page[:groups])
              end
                      
    respond_to do |format|
      format.html
      format.txt { render :text => @groups.map(&:title).join("\n") }
    end
  end
  
  def show
    if @group.forum
      @forum = @group.forum
      @topics = @forum.topics.paginate(:page => current_page, :per_page => per_page)
    end
  end
  
  def new
    @group = Group.new
  end
  
  def edit
  end
  
  def create
    @group = Group.new(params[:group])
    @group.owner = current_user
    
    if @group.save
      flash[:notice] = "#{escape_once @group.title} group created successfully."
      redirect_to group_path(@group)
    else
      render :action => :new
    end
  end
  
  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = "'#{escape_once @group.title}' group updated successfully."
      redirect_to group_path(@group)
    else
      render :action => :edit
    end
  end
  
  protected
    def find_user
      @user = params[:user_id] ? User.find_by_login!(params[:user_id]) : nil
    end
    
    def find_group
      @group = Group.find_by_url!(params[:id])
    end
end
