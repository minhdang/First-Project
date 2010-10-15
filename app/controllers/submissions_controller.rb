class SubmissionsController < ApplicationController
  ssl_required :show, :new, :create, :edit, :agreement, :update
  
  before_filter :capture_coupon
  before_filter :login_required
  before_filter :find_user
  before_filter :find_lps, :except => [:index]
  before_filter :find_idea, :only => [:create, :edit, :agreement, :battelle, :redeem, :redeem_agreement, :update, :show, :destroy]
  before_filter :find_submission, :only => [:create, :edit, :agreement, :battelle, :redeem, :redeem_agreement, :update, :show, :destroy]
  before_filter :handle_closed_lps, :except => [:index,:destroy], :unless => :submission_complete?
  before_filter :handle_open_search, :only => [:new, :create, :edit, :agreement, :battelle, :redeem, :redeem_agreement, :update]
  before_filter :redirect_non_insider_on_open_search, :only => [:update]
  before_filter :open_search_opt_in_check, :only => [:update,:edit]
  
  
  def index
    @submissions = @user.submissions.complete.paginate(:page => params[:page], :per_page => App.per_page[:submissions])
    render :layout => 'dashboard'
  end
  
  def show
    if @submission.complete?
     
    else
      redirect_to(edit_live_product_search_idea_submission_path(@lps, @idea))
    end
  end
  
  def new
    @ideas = @user.ideas.available_for(@lps).paginate(:page => params[:page], :per_page => App.per_page[:ideas])
    # If the user doesn't have any ideas to submit, make a new idea
    redirect_to new_live_product_search_idea_path(@lps) if @ideas.empty?
  end
  
  def create    
    redirect_to edit_live_product_search_idea_submission_path(@lps, @idea)
  end
  
  def edit
    redirect_to agreement_live_product_search_idea_submission_path(@lps,@idea) unless @lps.questions.any?
    @submission.build_answers
  end
  
  def agreement
    @submission.update_attribute(:coupon, nil)
    if session[:coupon_code]
      @coupon = Coupon.valid.find_by_code(session[:coupon_code])
      @submission.update_attribute(:coupon, @coupon) if @coupon && @coupon.applicable?(@submission, current_user)
    end
  
    @submission.infer_contact_information unless @submission.contact_information
    unless @submission.payment
      @submission.build_payment
      @submission.payment.build_billing_address
    end

  end
  
  def redeem
    session[:coupon_code] = 'rewardpoint'
    redirect_to agreement_live_product_search_idea_submission_path(@lps, @idea)
  end

  def battelle
    session[:coupon_code] = 'battelle'
    redirect_to agreement_live_product_search_idea_submission_path(@lps, @idea)
  end
  
  def update
    # Set protected attributes
    @submission.set_protected_term_attributes(params[:submission]) if params[:accepting_terms]
    
    referring_action = (params[:agreement] ? :agreement : :edit)
    if @submission.update_attributes(params[:submission])
      if referring_action == :agreement # We're sending data from the agreement page
        # Attempt to upgrade the user to Gold if they checked the box
        RewardPointValue.new_submission(@submission,current_user)
        unless !params[:upgrade_to_gold] || @user.upgrade!(params[:submission][:payment_attributes])
          @submission.errors.add_to_base("There was an error processing your Edison Insider payment: #{@user.membership.payment.errors.full_messages.to_sentence}")
          render(:agreement) and return
        end
      
        if @submission.complete? || @submission.complete!
          session[:coupon_code] = nil # Clear any coupon info the might have stored
          if @submission.coupon
            if @submission.coupon.code == 'rewardpoint'
              RewardPointValue.deduct_submission(current_user)
            end
          end
          redirect_to live_product_search_idea_submission_path(@lps, @idea)
        else
          render :agreement
        end
      else # We're sending data from the edit page
        if params[:commit] == 'Save for Later'
          flash[:notice] = Submission::UpdatedMessage
          redirect_to ideas_dashboard_path
        else
          redirect_to agreement_live_product_search_idea_submission_path(@lps, @idea)
        end
      end
    else
      # Build nested attributes
      @submission.infer_contact_information unless @submission.contact_information
      @submission.build_payment unless @submission.payment
      @submission.payment.build_billing_address unless @submission.payment.billing_address
      render referring_action
    end
  end
  
  def destroy
    if @submission.archive!
      flash[:notice] = 'Your submission was archived. It will no longer show up on your ideas dashboard.'
    else
      flash[:error] = 'There was an error archiving your submission.'
    end
    
    redirect_to ideas_dashboard_path
  end
  
  protected
  
    def find_user
      @user = current_user
    end
    
    def find_lps
      @lps = LPS.find_by_key!(params[:live_product_search_id])
    end
    
    def find_idea
      @idea = @user.ideas.find(params[:idea_id])
    end
    
    def find_submission
      @submission = @idea.submission_for(@lps)
    end
    
    def submission_complete?
      @submission && @submission.complete?
    end
    
    def open_search_opt_in_check
      if @lps.member_search && @idea.submissions_count >= 1
        flash['notice'] = 'Opt ins are not allowed for this search.'
        redirect_to dashboard_path
      end
    end
    
    
    def redirect_non_insider_on_open_search
      if @lps.member_search && !current_user.member
        flash['notice'] = 'This search is for Insiders only'
        redirect_to dashboard_path
      end
    end
    
    def handle_open_search
      user = current_user
      lps = LPS.find_by_key!(params[:live_product_search_id])
      if lps.member_search? && !current_user.member?
        redirect_to searches_path
      end
    end
  
end
