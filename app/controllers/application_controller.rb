class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_user_session

  before_filter :require_valid_user!

  #check_authorization

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = Roster::Session.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session && current_user_session.person
  end

  def require_valid_user!(return_to=url_for(only_path: false))
    session[:redirect_after_login] = return_to if return_to
    #puts "Setting redirec to #{return_to}"
    unless current_user_session
      respond_to do |fmt|
        fmt.html{ redirect_to new_roster_session_path }
        fmt.json{ head :unauthorized }
        fmt.ics{ head :unauthorized }
      end
    else 
      true
    end
  end

end
