class Admin::AttachmentsController < Admin::AdminController
  role_required [:superuser, :lps_admin, :lps_judge, :lps_commentator], :show, :create
  
  def show
    @attachment = Attachment.find(params[:id])
    if @attachment.file.exists?
      redirect_to @attachment.file.temporary_url
    elsif((@temp_attachment = TempAttachment.find(@attachment.id)) && @temp_attachment.file.exists?)
      send_file @temp_attachment.file.path
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def create
    @idea = Idea.find(params[:idea_id])
    @attachment = @idea.temp_attachments.new(params[:attachment])
    
    if @attachment.save
      flash[:notice] = 'Attachment was uploaded successfully'
    else
      flash[:error] = "Error uploading attachment: #{@attachment.errors.full_messages.to_sentence}"
    end
    redirect_to :back
  end
  
end
