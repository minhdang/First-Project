class MembershipsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  ssl_required :new, :edit, :create, :update
  
  before_filter :login_required
  before_filter :load_membership, :except => [:new, :create]
  before_filter :membership_required, :except => [:new, :create, :edit, :update]
  before_filter :ensure_not_already_a_member, :only => [:new, :create]
  
  def show
    flash.now[:error] =   "Your account is currently past due. If you do not enter "   \
                          "your information #{link_to 'here', edit_membership_path} "  \
                          "by #{@membership.auto_cancel_at.to_s(:long)} your account " \
                          "will be automatically canceled." if @membership.auto_cancel_at
  end
  
  def new
    @membership = Membership.new
    @membership.build_payment
    @membership.payment.build_billing_address
  end
  
  def edit
    flash.now[:error] =   "Your account is currently past due. Upon entering your information, "               \
                          "your card will be charged #{number_to_currency App.membership_cost}. "              \
                          "If you do not enter your information by #{@membership.auto_cancel_at.to_s(:long)} " \
                          "your account will be automatically canceled." if @membership && @membership.auto_cancel_at
  end
  
  def create
    @membership         = Membership.new(params[:membership])
    @membership.user    = current_user
    @membership.cost    = App.membership_cost
    
    if @membership.save
      if @membership.activate!
        flash[:notice] = 'Congratulations! You are now an Insider!'
        RewardPointValue.new_member(@membership.user)
        redirect_to membership_path
      else
        render :action => :edit
      end
    else
      render :action => :new
    end
  end
  
  def update
    if @membership.update_attributes(params[:membership]) && @membership.activate!
        flash[:notice] = "Thank you. Your payment information has been updated successfully.#{ ' You are now an Insider!' if @membership.recently_enrolled?}"
        redirect_to membership_path
    else
      flash.now[:error] = 'There was an error updating your payment information. Please review your information and try again.'
      @membership.build_payment if @membership.payment.blank?
      render :action => :edit
    end
  end
  
  # Cancel this users membership
  def destroy
    @membership.cancel!
    flash[:notice] = 'Your Insider membership has been downgraded. You will no longer be charged for Insider membership.'
    redirect_to new_membership_path
  end
  
  protected
    def load_membership
      @membership = current_user.membership
    end

    def ensure_not_already_a_member
      not_a_member = !current_user.member?
      unless not_a_member
        flash[:notice] = 'You are already an Insider.'
        redirect_to membership_path
      end
      not_a_member
    end
end