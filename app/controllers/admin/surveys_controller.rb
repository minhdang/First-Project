class Admin::SurveysController < Admin::AdminController
  
  before_filter :find_survey, :only => [:show, :edit, :update, :destroy]
  
  def index
    @surveys = Survey.paginate(:page => params[:page], :per_page => App.admin_per_page[:surveys])
  end
  
  def show
  end
  
  def new
    @survey = Survey.new
  end
  
  def edit
  end
  
  def create
    @survey = Survey.new(params[:survey])
    @survey.move_to_state(params[:survey][:state]) if params[:survey][:state]
    
    if @survey.save
      flash[:notice] = 'The survey was successfully created'
      redirect_to admin_survey_path(@survey)
    else
      render :new
    end
  end
  
  def update
    @survey.move_to_state(params[:survey][:state]) if params[:survey][:state]
    if @survey.update_attributes(params[:survey])
      flash[:notice] = 'The survey was successfully updated'
      redirect_to admin_survey_path(@survey)
    else
      render :edit
    end
  end
  
  def destroy
    @survey.destroy
    flash[:notice] = 'The survey was successfully destroyed'
    redirect_to admin_surveys_path
  end
  
  protected
  
    def find_survey
      @survey = Survey.find_by_url!(params[:id])
    end
  
end
