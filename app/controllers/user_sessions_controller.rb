class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  skip_before_filter :verify_authenticity_token, :only => [:new, :create]
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default dashboard_index_path
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    clear_current_user
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end
