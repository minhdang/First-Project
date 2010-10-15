class UserPhotoObserver < ActiveRecord::Observer
  
  def after_create(user_photo)
    # Create a notice that the user has added a video if it is the first one today
    user_photo.user.send_later(:notice!,user_photo) if Notice.similar(user_photo).today.count == 0
  end
  
end