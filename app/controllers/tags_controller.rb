class TagsController < ApplicationController
  def index
    @tags = params[:tag] ? Tag.search(params[:tag]) : nil

    respond_to do |format|
      format.json { render :json => @tags.map(&:title) }
    end
  end

end
