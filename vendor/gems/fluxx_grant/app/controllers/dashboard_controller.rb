class DashboardController < ApplicationController
  def index
    if current_user.is_grantee?
      redirect_back_or_default grantee_portal_index_path
    elsif current_user.is_reviewer?
      redirect_back_or_default reviewer_portal_index_path
    else
      render :index, :layout => nil
    end
  end
end
