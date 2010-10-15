class NeedTag < ActiveRecord::Base
  belongs_to :tag, :counter_cache => :needs_count
  belongs_to :need
  
  validates_uniqueness_of :tag_id, :scope => :need_id, :message => 'can only be used once per need'
end