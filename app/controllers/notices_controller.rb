class NoticesController < ApplicationController
  
  before_filter :login_required, :except => :feed
  before_filter :find_user, :except => :feed
  before_filter :handle_user, :except => :feed
  before_filter :owner_or_friend_required, :only => :index
  before_filter :owner_required, :only => :destroy
  
  def index
    @notices =  @user == current_user ?
                @user.notices.paginate(:page => params[:page], :per_page => App.per_page[:notices]) :
                @user.created_notices.original.paginate(:page => params[:page], :per_page => App.per_page[:notices])
  end
  
  def feed
    @notices = Notice.original.ordered.limit(10) #.with_complex_index
    @notices = @notices.created_after(Time.zone.parse(params[:last_published_at])) unless params[:last_published_at].blank?
    respond_to do |wants|
      wants.xml
    end
  end
  
  def destroy
    @notice = @user.created_notices.find(params[:id])
    @user.unnotice!(@notice.noticeable)
    flash[:notice] = 'The update was successfully deleted. It will no longer show up in your friends activity lists.'
    redirect_to user_path(@user)
  end
  
  protected
  
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def owner_or_friend_required
      owner_or_friend = ((@user == current_user) || @user.friends_with?(current_user))
      unless owner_or_friend
        redirect_to user_path(@user)
      end
      owner_or_friend
    end
    
    def owner_required
      owner = (@user == current_user)
      unless owner
        redirect_to user_path(@user)
      end
      owner
    end
  
end
