class Admin::QuestionsController < Admin::AdminController
  role_required [:superuser, :lps_admin], :index, :create, :update, :destroy
  
  before_filter :find_lps
  before_filter :find_question, :only => [:update, :destroy]
  
  def index
  end
  
  def create
    @question = Question.new(params[:question])
    @question.live_product_search = @lps
    
    if @question.save
      flash[:notice] = 'The question was successfully created.'
      redirect_to admin_live_product_search_questions_path(@lps)
    else
      render :index
    end
  end
  
  def update
    if @question.update_attributes(params[:question])
      flash[:notice] = 'The question was successfully updated.'
    else
      flash[:error] = "There was an error updating the question: #{@question.errors.full_messages.to_sentence}"
    end
    redirect_to admin_live_product_search_questions_path(@lps)
  end
  
  def destroy
    @question.destroy
    flash[:notice] = 'The question was successfully destroyed.'
    redirect_to admin_live_product_search_questions_path(@lps)
  end
  
  protected
    
    def find_lps
      @lps = LiveProductSearch.find_by_key!(params[:live_product_search_id])
    end
    
    def find_question
      @question = @lps.questions.find(params[:id])
    end
end
