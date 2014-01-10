require 'net/https'

class Roster::SessionsController < ApplicationController
  respond_to :html, :json

  newrelic_ignore only: [:new]

  skip_before_filter :require_valid_user!
  skip_before_filter :require_active_user!

  def logout
    destroy
  end

  def new

    if current_user_session
      redirect_to(request.env['SET_RETURN_TO'] || session[:redirect_after_login] || root_path) and return
    elsif path = request.env['SET_RETURN_TO']
      session[:redirect_after_login] = path
    end

    respond_with resource
  end

  def create
    resource = Roster::Session.new params[:roster_session]
    
    unless resource.save
      # Try these credentials against VC
      person = try_validate_vc_credentials(resource.username, params[:roster_session][:password])
      if person
        # Save these credentials so we don't look them up next time
        person.username = resource.username
        person.password = params[:roster_session][:password]
        person.save
      else
        flash.now[:error] = "Your username and/or password was not recognized by Volunteer Connection.  Please verify you have entered it correctly."
      end
    end

    if resource.save
      resource.person.last_login = Time.now
      resource.person.save
      if session[:redirect_after_login]
        redirect_to session[:redirect_after_login]
        session[:redirect_after_login] = nil
      else
        redirect_to roster_person_path(resource.person)
      end
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

  private

  def try_validate_vc_credentials(username, password)
    uri = URI.parse("https://volunteerconnection.redcross.org")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({user: username, password: password, fail: 'login', login: 'Login', succeed: 'm_home', nd: 'm_home'})
    response = http.request(request)
    matches = response.body.scan(/<h2><a href='\/\?nd=profile&account_id=(\d+)'>([^<]+)<\/a><\/h2>/)
    if matches.count > 0
      return Roster::Person.for_vc_account(matches.first[0])
    else
      return nil
    end
  end

  helper_method :resource
  def resource
    @resource ||= (current_user_session || Roster::Session.new)
  end

end
