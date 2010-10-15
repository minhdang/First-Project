class Admin::RatingsController < Admin::AdminController
  role_required [:superuser, :lps_admin, :lps_judge, :lps_commentator], :create, :update
  
  before_filter :find_rating, :only => [:update, :destroy]
  
  def create
    @submission   = Submission.find(params[:submission_id])
    @rating       = @submission.ratings.build(params[:rating])
    @rating.user  = current_user
    
    respond_to do |format|
      format.html {
        if @rating.save
          flash[:notice] = "You're rating was successfully saved"
        else
          flash[:error] = "Error rating submission: #{@rating.errors.full_messages.to_sentence}"
        end
        redirect_to admin_live_product_search_submission_path(@submission.live_product_search, @submission)
      }
      format.js {
        flash.now[:error] = "Error rating submission: #{@rating.errors.full_messages.to_sentence}" unless @rating.save
        render          
      }
    end
  end
  
  def update
    @rating = Rating.find(params[:id])
    
    respond_to do |format|
      format.html {
        if @rating.update_attributes(params[:rating])
          flash[:notice] = "You're rating was successfully updated"
        else
          flash[:error] = "Error rating submission: #{@rating.errors.full_messages.to_sentence}"
        end
        redirect_to admin_live_product_search_submission_path(@rating.submission.live_product_search, @rating.submission)
      }
      format.js {
        unless @rating.update_attributes(params[:rating])
          flash.now[:error] = "Error rating submission: #{@rating.errors.full_messages.to_sentence}"
        end
        render          
      }
    end
  end
  
  protected
    
    def find_rating
      @rating = Rating.find(params[:id])
    end
  
end
