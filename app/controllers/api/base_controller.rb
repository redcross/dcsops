class Api::BaseController < ActionController::Base
  include Connect::ControllerAdditions
  protect_from_forgery with: :null_session
  before_action :require_access_token
  before_action :allow_cors

  check_authorization

  def current_ability
    @ability ||= begin
      Api::Ability.new(current_access_token)
    end
  end

  def allow_cors
    origin = request.env['HTTP_ORIGIN']
    if origin =~ /(localhost|datresponse.org|dcsops.org)(:\d+)?\Z/
      puts 'CORS Matches'
      response.headers['Access-Control-Allow-Origin'] = origin
      response.headers['Access-Control-Allow-Methods'] = 'GET, HEAD, OPTIONS'
      response.headers['Vary'] = 'Origin'
    end
  end

  rescue_from CanCan::AccessDenied do |ex|
    render(json: {error: 'unauthorized'}, status: :forbidden)
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render(json: {error: 'not_found'}, status: :not_found)
  end
end
