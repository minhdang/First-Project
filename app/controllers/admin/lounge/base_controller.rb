class Admin::Lounge::BaseController < Admin::AdminController
  
  def index
    @announcement_count = Announcement.count
  end
  
  
end
