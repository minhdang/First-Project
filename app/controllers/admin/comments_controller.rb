class Admin::CommentsController < Admin::AdminController
  role_required [:superuser, :lps_admin, :lps_judge, :lps_commentator], :create, :update, :destroy
  
  before_filter :find_comment, :only => [:update, :destroy]
  
  def create
    @idea               = Idea.find(params[:idea_id])
    @submission         = @idea.submissions.find(params[:submission_id]) unless params[:submission_id].blank?
    
    @comment            = current_user.comments.new(params[:comment])
    @comment.idea       = @idea
    @comment.submission = @submission
    
    respond_to do |format|
      if @comment.save
        format.html {flash[:notice] = 'Your comment was successfully posted'; redirect_to :back;}
        format.js
      else
        format.html {flash[:error] = "Error posting comment: #{@comment.errors.full_messages.to_sentence}"; redirect_to :back;}
        format.js   {flash.now[:error] = "Error posting comment: #{@comment.errors.full_messages.to_sentence}"}
      end
    end
  end
  
  def update    
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { flash[:notice] = 'Your comment was successfully updated'; redirect_to :back; }
        format.js
      else
        format.html { flash[:error] = "Error posting comment: #{@comment.errors.full_messages.to_sentence}"; redirect_to :back; }
        format.js   { flash.now[:error] = "Error posting comment: #{@comment.errors.full_messages.to_sentence}" }
      end
    end
  end
  
  def destroy
    @comment.destroy
    
    respond_to do |format|
      format.html { flash[:success] = 'The comment was successfully removed.'; redirect_to :back; }
      format.js
    end
  end
  
  protected
  
    def find_comment
      @comment = Comment.find(params[:id])
    end
end
