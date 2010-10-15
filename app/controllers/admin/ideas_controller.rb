class Admin::IdeasController < Admin::AdminController
  def index
    if params[:q]
      @ideas = Idea.search(params[:q], :page => params[:page], :per_page => App.admin_per_page[:submissions]) 
    else
      @search = Idea.complete.searchlogic(params[:search])
      @ideas  = @search.paginate(:all, :order => 'created_at DESC',
                             :page => params[:page],
                             :per_page => App.admin_per_page[:submissions])
    end
    respond_to do |format|
      format.html {}
      format.csv  {}
      format.txt  { render :text => @ideas.map(&:title).join("\n") }
    end
  end
  
  def patented
    @ideas = Idea.find(:all, :conditions => { :patent_issued => 1 }) 
    patented_ideas = FasterCSV.generate do |csv|
      # header row
      csv << ["Idea ID","Title", "User Name", "Patent Number", "Category", "Description"]
      # data row
      @ideas.each do |idea|
        patents = []
        idea.patents.each do |patent|
          patents << patent.patent_number
        end
        csv << [idea.id, idea.title, "#{idea.user.last_name} #{idea.user.first_name}", patents, idea.category.name, idea.detailed_description]
      end
    end
    send_data(patented_ideas, :type => 'text/csv', :filename => 'patented_ideas.csv')
  end
  
  def show
    @idea = Idea.find(params[:id])
  end
  
  def update
    @idea = Idea.find(params[:id])
    
    if @idea.update_attributes(params[:idea])
      flash[:notice] = 'The idea was successfully updated'
    else
      flash[:error] = 'There was an error updating the idea'
    end
    redirect_to :back
  end
end