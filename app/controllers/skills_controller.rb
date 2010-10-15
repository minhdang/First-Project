class SkillsController < ApplicationController
  def index
    respond_to do |format|
      format.html do        
        @newest_user_skills = UserSkill.find(:all, :select => 'DISTINCT(user_id)', :order => 'created_at DESC', :limit => App.newest[:user_skills])
      end
      format.txt do
        render :text => Skill.search(params[:q]).map(&:title).join("\n")
      end
    end
  end
  
  def show
    @skill = Skill.find_by_url!(params[:id])
    @users = @skill.users.paginate(:per_page => App.per_page[:skill_users], :page => params[:page])
  end
end