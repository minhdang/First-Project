class UserSkillsController < ApplicationController
  before_filter :login_required

  def create    
    @user_skill = current_user.user_skills.new(params[:user_skill])
    if @user_skill.save
      flash[:notice] = "'#{@user_skill.skill.title}' was added to your list of skills."
      redirect_to edit_user_path(current_user)
    else
      @user = current_user
      render :template => '/users/edit'
    end
  end

  def destroy
    @user_skill = UserSkill.find_by_user_id_and_skill_id!(current_user.id, Skill.find_by_url!(params[:id]).id)
    if @user_skill.destroy
      flash[:notice] = "'#{@user_skill.skill.title}' was removed from your list of skills."
    else
      flash[:error] = "'#{@user_skill.skill.title}' was not removed from your list of skills."
    end    
    redirect_to edit_user_path(current_user)
  end
end