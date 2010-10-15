class BlogEntryObserver < ActiveRecord::Observer
  
  def after_create(blog_entry)
    # Create a notice that the user has added a blog_entry
    blog_entry.bloggable.send_later(:notice!, blog_entry, true) if blog_entry.bloggable.class.name == 'User'
  end
  
end