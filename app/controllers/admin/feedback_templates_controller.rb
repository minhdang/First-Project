class Admin::FeedbackTemplatesController < Admin::AdminController
  
  def index
    @feedback_templates = FeedbackTemplate.all
  end
  
  def show
    @feedback_template = FeedbackTemplate.find(params[:id])
  end
  
  def new
    @feedback_template = FeedbackTemplate.new
  end
  
  def create
    @feedback_template = FeedbackTemplate.new(params[:feedback_template])
    if @feedback_template.save
      flash[:notice] = 'Your template was saved'
      redirect_to :action => 'index'
    else
      flash[:error] = 'There was a problem saving your template'
      render :action => 'new'
    end
  end
  
  def edit
    @feedback_template = FeedbackTemplate.find(params[:id])
  end
  
  def update
    @feedback_template = FeedbackTemplate.find(params[:id])
    if @feedback_template.update_attributes(params[:feedback_template])
      flash[:notice] = 'Your template has been updated'
      redirect_to admin_feedback_template_path(@feedback_template)
    else
      flash[:error] = 'There was a problem updating your template'
      render :action => 'edit'
    end
  end
  
  def destroy
    @feedback_template = FeedbackTemplate.find(params[:id])
    @feedback_template.destroy
    redirect_to admin_feedback_templates_path
  end
  
end
