class ConcentrationsController < ApplicationController
  def index
    @concentrations = Concentration.search(params[:q])
    respond_to do |format|
      format.txt { render :text => @concentrations.map(&:title).join("\n") }
    end
  end

end
