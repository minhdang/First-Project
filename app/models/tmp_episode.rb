class TmpEpisode < ActiveRecord::Base
  
  named_scope :all, :order => 'episode ASC'
  
end
