class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_user_session, :current_region, :impersonating_user

  before_action :require_valid_user!
  before_action :require_active_user!
  before_action :annotate_newrelic_user, :if => :current_user

  around_action :user_time_zone, :if => :current_user

  before_action :set_frame_options

  def user_time_zone(&block)
    tz = current_user.try(:region).try(:time_zone) || Time.zone 
    Time.use_zone(tz, &block)
  end

  def annotate_newrelic_user
    ::NewRelic::Agent.add_custom_parameters(user_id: current_user.try(:id), user_name: current_user.try(:full_name), region_id: current_region.id)
  end

  #check_authorization

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

  def current_region
    @current_region ||= current_user.region if current_user
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
    logged_in_user && AdminAbility.new(logged_in_user).can?(:impersonate, person)
  end

  def require_valid_user!(return_to=request.original_url)
    unless current_user_session
      session[:redirect_after_login] = return_to if return_to
      respond_with_redirect_or_status(new_roster_session_path, :unauthorized)
    end
  end

  def require_active_user!
    person = current_user_session.try(:person) || current_user
    if person and (!person.is_active? || filtered_person?(person))
      respond_with_redirect_or_status inactive_user_path, :forbidden
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    raise exception and return if Rails.env.test?
    flash[:error] = "You are not authorized to access that page."
    respond_with_redirect_or_status :back, :forbidden
  end

  def respond_with_redirect_or_status redirect, status, fallback=nil
    respond_to do |fmt|
      fmt.any(:html, :pdf) { redirect_to redirect }
      fmt.all { head status }
    end
  rescue ActionController::RedirectBackError
    redirect_to fallback||root_path
  end

  def set_frame_options
    if ENV['FRAME_EMBED_KEY'].present? && params[:embed_key] == ENV['FRAME_EMBED_KEY']
      response.headers.delete('X-Frame-Options')
    end
  end

  def filtered_person? person
    filter = ENV['LOGIN_FILTER']
    if filter && person.email
      regex = Regexp.new(filter)
      regex.match(person.email).present?
    else
      false
    end
  end



end
