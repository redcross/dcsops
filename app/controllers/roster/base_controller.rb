class Roster::BaseController < ApplicationController
  def current_ability
    @current_ability ||= Roster::Ability.new(current_user)
  end
end