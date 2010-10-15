class Admin::FeedbackController < Admin::AdminController
  
  def index
    #@submissions = Submission.find(:all , :conditions => ['feedback = ?', 'pending'], :limit => 10)
    @submissions = Submission.paginate :page => params[:page], :conditions => ['feedback = ?', 'pending'] ,:per_page => 10
  end
  
  def pending
    #@submissions = Submission.find(:all , :conditions => ['feedback = ?', 'pending'])
    @submissions = Submission.paginate :page => params[:page], :conditions => ['feedback = ?', 'pending'] ,:per_page => 10
    render :template => 'admin/feedback/index'
  end
  
  def complete
    #@submissions = Submission.find(:all , :conditions => ['feedback = ?', 'complete'])
    @submissions = Submission.paginate :page => params[:page], :conditions => ['feedback = ?', 'complete'] ,:per_page => 10
    render :template => 'admin/feedback/index'
  end
  
end
