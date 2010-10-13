class ApplicationController < ActionController::Base
  before_filter :require_user
  protect_from_forgery

  before_filter :set_time_zone

  def set_time_zone
    Time.zone = current_user.time_zone if current_user && current_user.time_zone
  end

  helper :all
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    User.suspended_delta do
      User.without_realtime do
        User.without_auditing do
          return @current_user if defined?(@current_user)
          @current_user = current_user_session && current_user_session.user
        end
      end
    end
  end
    
  protected
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        # flash[:notice] = "You must be logged out to access this page"
        redirect_to dashboard_index_path
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(default || '/')
      session[:return_to] = nil
    end
end
