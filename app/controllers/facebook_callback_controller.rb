class FacebookCallbackController < ApplicationController
  
  def create
    respond_to do |format|
      format.html { 
        redirect_to root_url
      }
      format.js {
        facebook_like       = FacebookLike.new
        facebook_like.user  = params[:body][:login]
        facebook_like.url   = params[:body][:liked]
        facebook_like.save
      }
    end
  end
  
end
