class AttachmentsController < ApplicationController
  ssl_required :index, :show, :create, :destroy
  
  before_filter :login_required
  before_filter :find_user
  before_filter :find_idea
  before_filter :find_lps
  
  def index
    @attachment  = Attachment.new
    @attachments = @idea.attachments.all
  end
  
  def show
    @attachment = @idea.attachments.find(params[:id])
    
    if @attachment.file.exists?
      redirect_to @attachment.file.temporary_url
    elsif((@temp_attachment = TempAttachment.find(@attachment.id)) && @temp_attachment.file.exists?)
      send_file @temp_attachment.file.path
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def create
    @attachment = @idea.temp_attachments.new(params[:attachment] || params[:temp_attachment])
    
    if @attachment.save
      target = @lps ?
        live_product_search_idea_attachments_path(@lps, @idea) :
        idea_attachments_path(@idea)
      redirect_to target
    else
      @attachments = @idea.attachments.all
      render :index, :status => :bad_request
    end
  end
  
  def destroy
    @attachment = @idea.attachments.find(params[:id])
    @attachment.destroy
    
    flash[:notice] = 'The attachment was removed successfully'
    target = @lps ?
      live_product_search_idea_attachments_path(@lps, @idea) :
      idea_attachments_path(@idea)
    redirect_to target
  end
  
  protected
    
    def find_user
      @user = current_user
    end
    
    def find_idea
      @idea = @user.ideas.find(params[:idea_id])
    end
    
    def find_lps
      @lps = LPS.find_by_key!(params[:live_product_search_id]) if params[:live_product_search_id]
    end
end
