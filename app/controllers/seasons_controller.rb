class SeasonsController < ApplicationController
  
  def index
    @seasons = Season.all
  end
end
