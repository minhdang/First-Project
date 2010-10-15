class VideoCategoriesController < ApplicationController

  def show
    @video_category = VideoCategory.find_by_url!(params[:id])
  end

end
