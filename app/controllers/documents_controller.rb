class DocumentsController < ApplicationController
  
  def show    
    @document = Document.find_by_url!(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf  { send_file(@document.pdf.path, :type => :pdf) }
    end
  end
  
end
