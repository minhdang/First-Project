class StoresController < ApplicationController
  before_filter :find_store
  before_filter :find_cart
  
  def show  
  end
  
  protected
  
    def find_store
      @store = Store.find_by_url!(params[:id])
    end
  
end
