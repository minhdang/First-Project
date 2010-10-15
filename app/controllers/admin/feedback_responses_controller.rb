class Admin::FeedbackResponsesController < Admin::AdminController
  
  def index
    
  end
  
  def show
    
  end
  
  def new
    @feedback_templates = FeedbackTemplate.all
    @submission = Submission.find_by_key!(params[:submission_key])
  end
  
  def create
    fr = FeedbackResponse.new
    flash[:notice] = 'Awesome! it worked...'
    redirect_to admin_feedback_index_path
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  # extras
  
  def get_template
    @feedback_template = FeedbackTemplate.find(params[:id])
    
    respond_to do |format|
      format.js { }
    end
  end
  
end
