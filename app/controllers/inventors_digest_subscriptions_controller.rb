class InventorsDigestSubscriptionsController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :owner_required
  before_filter :inventors_digest_subscription_required
  
  def update
    if @user.inventors_digest_subscription.update_attributes(params[:inventors_digest_subscription])
      flash[:notice] = 'Your Inventors Digest subscription was successfully updated'
    else
      flash[:error] = "There was an error updating your subscription. #{@user.inventors_digest_subscription.errors.full_messages.to_sentence}"
    end
    redirect_to edit_user_path(@user)
  end
  
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
    
    def owner_required
      owner = current_user == @user
      unless owner
        redirect_to login_path
        return false
      end
      owner
    end
    
    def inventors_digest_subscription_required
      unless @user.inventors_digest_subscription
        redirect_to_referer
      end
       @user.inventors_digest_subscription
    end
  
end
