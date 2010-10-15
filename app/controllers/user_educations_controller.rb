class UserEducationsController < ApplicationController
  before_filter :login_required
  
  def create
    @education = current_user.educations.new(params[:education])
    
    if @education.save
      flash[:notice] = "#{@education.campus.title} has been added to your education list."
      redirect_to edit_user_path(current_user)
    else
      @user = current_user
      render :template => 'users/edit'
    end
  end
  
  def destroy
    @education = current_user.educations.find(params[:id])
    
    if @education.destroy
      flash[:notice] = "Your education was removed successfully."
    else
      flash[:error] = "There was an error removing your education."
    end
    
    redirect_to edit_user_path(current_user)
  end
end
