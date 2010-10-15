class SurveyResponsesController < ApplicationController
  ssl_required :new, :create, :agreement, :update
  
  before_filter :login_required
  before_filter :find_user
  before_filter :find_survey
  
  def new
    @response = @survey.build_response
  end
  
  def create
    @response = @survey.responses.new(params[:survey_response])
    @response.user = @user
    
    if @response.save
      redirect_to agreement_survey_response_path(@survey, @response)
    else
      render :new
    end
  end
  
  def agreement
    @response = @survey.responses.find(params[:id])
    
    @response.infer_contact_information unless @response.contact_information
    unless @response.free? || @response.payment
      @response.build_payment
      @response.payment.build_billing_address
    end
  end
  
  def update
    @response = @survey.responses.find(params[:id])
    
    # Set protected attributes
    @response.accepting_terms! if params[:accepting_terms]
    
    referring_action = (params[:agreement] ? :agreement : :edit)
    if @response.update_attributes(params[:survey_response])
      if referring_action == :agreement # We're sending data from the agreement page
        # Attempt to upgrade the user to Gold if they checked the box
      
        if @response.complete? || @response.complete!
          flash[:modal] = 'Your idea was successfully submitted to the Name Search. Thank you and good luck.'
          redirect_to dashboard_path
        else
          render :agreement
        end
      else # We're sending data from the edit page
        redirect_to agreement_survey_response_path(@survey, @response)
      end
    else
      # Build nested attributes
      @response.infer_contact_information unless @response.contact_information
      @response.build_payment unless @response.payment
      @response.payment.build_billing_address unless @response.payment.billing_address
      
      render referring_action
    end
  end
  
  protected
  
    def find_user
      @user = current_user
    end
    
    def find_survey
      @survey = Survey.find_by_url!(params[:survey_id])
    end
end
