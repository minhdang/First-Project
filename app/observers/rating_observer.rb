class RatingObserver < ActiveRecord::Observer
  
  def after_save(rating)
    rating.user.send_later(:notice!, rating, public_notice = false)
  end
  
end