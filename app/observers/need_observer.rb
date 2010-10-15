class NeedObserver < ActiveRecord::Observer
  
  def after_create(need)
    # Create a notice that the user has added a need
    need.user.send_later(:notice!,need,true)
  end
  
end