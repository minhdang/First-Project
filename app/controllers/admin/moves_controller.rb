class Admin::MovesController < Admin::AdminController
  role_required [:superuser, :lps_admin, :lps_judge, :lps_commentator], :update
  
  before_filter :find_move
  
  def update
    if @move.update_attributes(params[:move])
      flash[:notice] = 'The move was updated successfully'
    else
      flash[:error] = "There was an error updating the move: #{@move.errors.full_messages.to_sentence}"
    end
    redirect_to :back
  end
  
  def destroy
    if @move.destroy
      flash[:notice] = 'The move was successfully destroyed and the submission has been rolled back.'
    else
      flash[:error]  = "Error destroying move: #{@move.errors.full_messages.to_sentence}"
    end
    redirect_to :back
  end
  
  protected
    def find_move
      @move = Move.find(params[:id])
    end
  
end