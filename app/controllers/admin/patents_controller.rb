class Admin::PatentsController < Admin::AdminController
  
  def show
    @patent = Patent.find(params[:id])
    
    if @patent.application?
      redirect_to @patent.application.temporary_url
    else
      render :nothing => true
    end
  end
  
end
