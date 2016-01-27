require 'net/https'

class Roster::SessionsController < ApplicationController
  respond_to :html, :json

  newrelic_ignore only: [:new]

  skip_before_filter :require_valid_user!
  skip_before_filter :require_active_user!

  def new

    if current_user_session
      redirect_to(request.env['SET_RETURN_TO'] || session[:redirect_after_login] || root_path) and return
    elsif path = request.env['SET_RETURN_TO']
      session[:redirect_after_login] = path
    end

    respond_with resource
  end

  def create
    if login_with_credentials resource.username, params[:roster_session][:password]
      resource.person.update_attribute :last_login, Time.now
      redirect_to after_login_path(resource.person)
    else
      render action: :new
    end
  end

  def show
    redirect_to action: :new
  end

  def destroy
    resource.destroy
    redirect_to new_roster_session_path
  end

  def omniauth_callback
    auth_env = request.env['omniauth.auth']
    puts auth_env.inspect

    rco_id = auth_env['uid']

    if user = person_for_rco_id(rco_id)
      Roster::Session.create!(user, true)
      user.update_attribute :last_login, Time.now
      redirect_to after_login_path(user)
    else
      session[:rco_id] = rco_id
      redirect_to action: :new_from_rco
    end
  end

  def new_from_rco
    unless session[:rco_id]
      redirect_to action: :new
      return
    end

    @session_rco_id = session[:rco_id]
  end

  private

  def after_login_path(person)
    session.delete(:redirect_after_login) || roster_person_path(person)
  end

  def person_for_rco_id(id)
    id.present? && Roster::Person.find_by(rco_id: id)
  end

  def login_with_credentials username, password
    service = Roster::LoginService.new(username, password)
    if resource.save
      service.deferred_update
      true
    else
      service.call
      resource.save
    end
  rescue Net::ReadTimeout, Net::OpenTimeout
    flash.now[:error] = "There was an error validating your password.  Please try again."
    false
  rescue Vc::Login::InvalidCredentials
    flash.now[:error] = "The credentials you provided are incorrect."
    false
  end

  helper_method :resource
  def resource
    @resource ||= (current_user_session || Roster::Session.new(params[:roster_session]))
  end

end
