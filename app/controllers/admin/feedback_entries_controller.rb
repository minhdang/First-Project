class Admin::FeedbackEntriesController <  Admin::AdminController
  
  before_filter :find_submission, :except => [:create]
  
  def new
    @feedback_templates = FeedbackTemplate.all
  end
  
  def create
    feedback_entry = FeedbackEntry.new(params[:feedback_entry])
    if feedback_entry.save
      submission = Submission.find_by_key(params[:submission_key])
      submission.feedback_entry = feedback_entry
      submission.feedback_complete
      flash[:notice] = 'Awesome!'
      #redirect_to admin_feedback_index_path
      redirect_to admin_live_product_search_submission_path(params[:lps_key], params[:submission_key])
    else
      flash[:error] = "D'oh! Something went wrong"
      render :action => 'new'
    end
  end
  
  def update
    feedback_entry = FeedbackEntry.find(params[:id])
    if feedback_entry.update_attributes(params[:feedback_entry])
      flash[:notice] = "Submission Feedback was updated"
      redirect_to admin_live_product_search_submission_path(params[:lps_key], params[:submission_key])
    else
      flash[:error] = "D'oh! Something went wrong"
      redirect_to admin_live_product_search_submission_path(params[:lps_key], params[:submission_key])
    end
  end
  
  def get_template
    @feedback_template = FeedbackTemplate.find(params[:id])
    
    respond_to do |format|
      format.js { }
    end
  end
  
  def find_submission
    @submission = Submission.find_by_key!(params[:submission_key])
  end
  
end
