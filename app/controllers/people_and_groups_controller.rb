class PeopleAndGroupsController < ApplicationController
  
  def index
    @popular_groups = Group.by_popularity.limited(10).all
  end
  
end
