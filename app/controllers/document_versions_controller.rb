class DocumentVersionsController < ApplicationController
  
  def show    
    @document = Document.find_by_url!(params[:document_id])
    @version  = @document.versions.find_by_version!(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf  { send_file(@version.pdf.path, :type => :pdf) }
    end
  end
  
end
