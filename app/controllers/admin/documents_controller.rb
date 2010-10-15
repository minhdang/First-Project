class Admin::DocumentsController < Admin::AdminController
  role_required [:superuser, :lps_admin], :new, :edit, :create, :update
  
  def index
    @documents = Document.all
  end
  
  def show
    @document = Document.find_by_url!(params[:id])
  end
  
  def new
    @document = Document.new
  end
  
  def edit
    @document = Document.find_by_url!(params[:id])
  end
  
  def create
    @document = Document.new(params[:document])
    
    if @document.save
      flash[:notice] = 'The document was successfully created'
      redirect_to admin_documents_path
    else
      render :new
    end
  end
  
  def update
    @document = Document.find_by_url!(params[:id])
    
    if @document.update_attributes(params[:document])
      flash[:notice] = 'The document was successfully updated'
      redirect_to admin_documents_path
    else
      render :edit
    end
  end
end
