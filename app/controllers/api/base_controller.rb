class Api::BaseController < ActionController::Base
  include Connect::ControllerAdditions
  protect_from_forgery with: :null_session
  before_filter :require_access_token

  check_authorization

  def current_ability
    @ability ||= begin
      Api::Ability.new(current_access_token)
    end
  end

  rescue_from CanCan::AccessDenied do |ex|
    render(json: {error: 'unauthorized'}, status: :forbidden)
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render(json: {error: 'not_found'}, status: :not_found)
  end
end
