class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  skip_before_filter :verify_authenticity_token, :only => [:new, :create]
  
  def new
    response.headers['fluxx_template'] = 'login'
    @user_session = UserSession.new
    respond_to do |format|
      format.html do
        render :action => 'new.html.haml'
      end
      format.json do
        render :action => 'new.html.haml'
      end
    end
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
