class PreferencesController < ApplicationController
  before_filter :login_required
  before_filter :find_preferences
  
  skip_before_filter :verify_authenticity_token
  
  def create
    @preferences.update_attributes(params[:preferences])
    redirect_to_referer
  end
  
  def update
    @preferences.update_attributes(params[:preferences])
    redirect_to_referer
  end
  
  def mute_topic
    @topic = Topic.find(params[:topic_id])
    if @topic && @preferences.muted_topics << @topic.id && @preferences.save
      flash[:notice] = "'#{@topic.title}' was muted and will not show up in your topics."
    else
      flash[:error] = 'There was an error muting this topic. Please try again.'
    end
    redirect_to_referer
  end
  
  def unmute_topic
    @topic = Topic.find(params[:topic_id])
    if @topic && @preferences.muted_topics.delete(@topic.id) && @preferences.save
      flash[:notice] = "'#{@topic.title}' was unmuted and will show up in your topics again."
    else
      flash[:error] = 'There was an error unmuting this topic. Please try again.'
    end
    redirect_to_referer
  end
  
  def mute_user
    @user = User.find(params[:user_id])
    if @user && @preferences.muted_users << @user.id && @preferences.save
      flash[:notice] = "'#{@user.name} (#{@user.login})' was muted and their posts will be minimized from now on."
    else
      flash[:error] = 'There was an error muting this user. Please try again.'
    end
    redirect_to_referer
  end
  
  def unmute_user
    @user = User.find(params[:user_id])
    if @user && @preferences.muted_users.delete(@user.id) && @preferences.save
      flash[:notice] = "'#{@user.name} (#{@user.login})' was unmuted."
    else
      flash[:error] = 'There was an error unmuting this user. Please try again.'
    end
    redirect_to_referer
  end
  
  protected
    def find_preferences
      @preferences = Preferences.find_or_create_by_user_id(current_user.id)
    end
  
end
