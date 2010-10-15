class SurveysController < ApplicationController
  
  def show
    @survey = Survey.find_by_url!(params[:id])
  end
  
end
