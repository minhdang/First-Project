class UserVideoObserver < ActiveRecord::Observer
  
  def after_create(user_video)
    # Create a notice that the user has added a video if it is the first one today
    user_video.user.send_later(:notice!,user_video) if Notice.similar(user_video).today.count == 0
  end
  
end