class Admin::SubmissionsController < Admin::AdminController
  role_required [:superuser, :lps_admin, :lps_judge, :lps_commentator], :index, :show, :update
  
  before_filter :find_lps, :only => [:index, :show, :update]
  before_filter :find_submission, :only => [:show, :update]
  
  # GET /admin/live_product_searches/:lps_id/submissions
  def index
    @submissions = if params[:q]
        Submission.search(params[:q],
          :conditions => {:live_product_search_id => @lps.id},
          :page => current_page, :per_page => App.admin_per_page[:submissions])
      else
        @search = @lps.submissions.searchlogic(params[:search])
        @search.paginate(:page => params[:page], :per_page => App.admin_per_page[:submissions], :include => [:user, :idea], :order => 'created_at DESC')
      end
    
    respond_to do |format|
      format.html
      format.csv
      format.txt  { render :text => @submissions.map {|s| "#{s.idea.title}"}.join("\n") }    
    end
  end
  
  # GET /admin/live_product_searches/:lps_id/submissions/:id
  def show
  end
  
  # POST /admin/ideas/:idea_id/submissions
  def create
    @idea       = Idea.find(params[:idea_id])
    @lps        = LPS.find_by_key!(params[:submission][:live_product_search_id])
    @submission = @idea.submission_for(@lps)
    @latest_submission = @idea.user.latest_submission
    
    @submission.instance_variable_set(:@fee, 0.0)
    if @latest_submission
      @submission.contact_information = @latest_submission.contact_information.clone
      @submission.signature = @latest_submission.signature
      @submission.agreement_version = Document.innovator_agreement.version
      %w(agree_to_terms agree_to_submission_fee agree_to_age_requirements agree_to_no_feedback).each do |agreement|
        @submission.send(:"#{agreement}=", true)
      end
    end
    
    if @submission.complete!
      flash[:notice] = "Sucessfully submitted idea to #{@lps.title}"
      redirect_to admin_live_product_search_submission_path(@lps,@submission)
    else
      flash[:error] = "Error submitting idea: #{@submission.errors.full_messages.to_sentence}"
      redirect_to :back
    end
  end
  
  
  # PUT /admin/live_product_searches/:lps_id/submissions/:id
  def update
    @action  = params[:commit]
    @success = (@action == 'pass') ?
      @submission.pass!(:user => current_user) :
      @submission.fail!(:user => current_user)
    
    respond_to do |format|
      format.html { redirect_to admin_live_product_search_submission_path(@lps,@submission) }
      format.js   {
        # smelly should check current stage then find the templates
        @feedback_templates = FeedbackTemplate.all
      }
    end
  end
  
  def get_template
    # couldn't use before filter lookups for LPS and Submission because of the diff in params
    @feedback_template = FeedbackTemplate.find(params[:feedback_template_id])
    @submission = Submission.find_by_key!(params[:id])
    @lps = LPS.find_by_key!(params[:live_product_search_id])
    
    respond_to do |format|
      format.js { }
    end
  end

  
  protected
    def find_lps
      @lps = LPS.find_by_key!(params[:live_product_search_id])
    end
  
    def find_submission
      @submission = @lps.submissions.find_by_key!(params[:id])
    end
  
end