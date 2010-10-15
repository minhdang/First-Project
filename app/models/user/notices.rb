class User
  
  has_many :notices, :conditions => {:public_notice => true}, :order => 'created_at DESC', :dependent => :destroy
  has_many :created_notices, :class_name => 'Notice', :foreign_key => :creator_id, :conditions => {:public_notice => true}, :order => 'created_at DESC', :dependent => :destroy
  
  def notice!(noticeable, public_notice = false)
    Notice.create(:creator => self, :noticeable => noticeable, :public_notice => public_notice)
  end
  
  def unnotice!(noticeable)
    Notice.destroy_all(:creator_id => self.id, :noticeable_type => noticeable.class.name, :noticeable_id => noticeable.id)
  end
  
end