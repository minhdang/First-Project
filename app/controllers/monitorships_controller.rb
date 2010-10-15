class MonitorshipsController < ApplicationController
  before_filter :login_required
  before_filter :find_forum_and_topic
  
  skip_before_filter :verify_authenticity_token
  
  def create
    monitorship = current_user.monitor_topic(@topic)
    
    flash[:notice] = "You are now subscribed to this topic. You will be notified when other users reply to this topic."
    redirect_to_referer
  end
  
  def destroy
    monitorship = current_user.monitorships.find(:first, :conditions => {:topic_id => @topic.id, :active => true})
    if monitorship && Monitorship.update_all('active = 0', "id = #{monitorship.id}")
      flash[:notice] = "You will no longer be notified when other users reply to this topic."
    else
      flash[:error] = "There was a problem unsubscribing to this topic. Please try again."
    end
    redirect_to_referer
  end
  
  protected
    def find_forum_and_topic
      @forum = Forum.find_by_url!(params[:forum_id])
      @topic = @forum.topics.find_by_url!(params[:topic_id])
    end
  
end
