module TagsHelper

  def linked_list_of_tags(tags)
    tags.collect {|tag| link_to tag.title, needs_path(:q => tag.title)}.join(', ')
  end
  
end
