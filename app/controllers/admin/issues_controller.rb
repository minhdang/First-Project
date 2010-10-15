class Admin::IssuesController < Admin::AdminController
  
  role_required :staff, :index, :show, :new, :create, :edit, :update, :destroy
  
  def index
    @issues = Issue.all
  end

  def new
    @issue = Issue.new
  end
  
  def create
    @issue = Issue.new(params[:issue])
    if @issue.save
      flash[:notice] = "The issue created successfully!"
      redirect_to admin_issues_path
    else
      render :action => :new
    end
  end
  
  def edit
    @issue = Issue.find(params[:id])
  end
  
  def update
    @issue = Issue.find(params[:id])
    if @issue.update_attributes(params[:issue])
      flash[:notice] = "The issue updated successfully"
      redirect_to admin_issues_path
    else
      render :action => :edit
    end
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    flash[:notice] = "The issue destroyed successfully"
    redirect_to admin_issues_path
  end
end
