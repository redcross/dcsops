class Roster::BaseController < ApplicationController
  def current_ability
    @current_ability ||= oauth_api_user ? ApiAbility.new(oauth_api_user) : Roster::Ability.new(current_user)
  end
end