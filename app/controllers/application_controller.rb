class ApplicationController < ActionController::Base
  include OauthController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_user_session, :current_chapter, :impersonating_user

  before_filter :require_valid_user!

  around_filter :user_time_zone, :if => :current_user

  def user_time_zone(&block)
    tz = current_user.try(:chapter).try(:time_zone) || Time.zone 
    Time.use_zone(tz, &block)
  end

  #check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    raise exception and return if Rails.env.test?
    begin
      respond_to do |fmt|
        fmt.html{ flash[:error] = "You are not authorized to access that page."; redirect_to :back }
        fmt.pdf{ flash[:error] = "You are not authorized to access that page."; redirect_to :back }
        fmt.json{ head :forbidden }
        fmt.ics{ head :forbidden }
        fmt.kml{ head :forbidden }
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = Roster::Session.find
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session && (impersonating_user || current_user_session.person)
  end

  def logged_in_user
    current_user_session.try(:person)
  end

  def current_chapter
    @current_chapter ||= current_user.chapter
  end

  def impersonating_user
    return @impersonating_user if defined?(@impersonating_user)

    person = session[:impersonating_user_id] && Roster::Person.find_by( id: session[:impersonating_user_id])

    if person and !can_impersonate(person)
      person = nil
    end

    @impersonating_user = person
  end

  def can_impersonate(person)
    AdminAbility.new(current_user_session.person).can?(:impersonate, person)
  end

  def require_valid_user!(return_to=url_for(only_path: false))
    #puts "Setting redirec to #{return_to}"
    unless current_user_session || oauth2_api_user
      session[:redirect_after_login] = return_to if return_to
      respond_to do |fmt|
        fmt.html{ redirect_to new_roster_session_path }
        fmt.pdf{ redirect_to new_roster_session_path }
        fmt.json{ head :unauthorized }
        fmt.ics{ head :unauthorized }
        fmt.kml{ head :unauthorized }
      end
    else 
      true
    end
  end

end
