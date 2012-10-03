# TODO ESH: add an su feature, per http://blog.steveklabnik.com/writing-a-su-feature-with-authlogic
class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  skip_before_filter :verify_authenticity_token, :only => [:new, :create]
  
  def new
    response.headers['fluxx_template'] = 'login'
    @user_session = UserSession.new
    respond_to do |format|
      format.html do
        Fluxx.config(:hide_lois) == "1" ? render(:action => 'new.html.haml') : render(:action => :portal, :layout => "portal")
      end
      format.json do
        render :action => 'new.html.haml'
      end
    end
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    User.suspended_delta(false) do
      User.without_realtime do
        User.without_auditing do
            if @user_session.save
              # ESH: total hack to not re-index delta; I couldn't find an appropriate place to tell TS not to toggle delta
              # this is bad because if somebody had legitimately toggled the delta to reindex this user, it will not get reindexed
              User.connection.execute User.send(:sanitize_sql, ["update users set delta = 0 where id = ?", @user_session.user.id])
              flash[:notice] = "Login successful!"
              if @user_session.user.is_grantee?
                redirect_back_or_default grantee_portal_index_path
              elsif @user_session.user.is_reviewer?
                redirect_back_or_default reviewer_portal_index_path
              else
                redirect_back_or_default dashboard_index_path
              end
            else
              if params["user_session"] && params["user_session"]["portal"]
                  render :action => :portal, :layout => "portal"
              else
                render :action => :new
              end
            end
        end
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    clear_current_user
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

  def portal
    if !current_user_session.nil?
      current_user_session.destroy
      clear_current_user
    end
    response.headers['fluxx_template'] = 'login'
    @user_session = UserSession.new
    respond_to do |format|
      format.html do
        render :action => :portal, :layout => "portal"
      end
    end
  end
end
