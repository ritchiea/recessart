class DashboardController < ApplicationController
  def index
    render :index, :layout => nil
  end
end
