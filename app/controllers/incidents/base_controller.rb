class Incidents::BaseController < ApplicationController
  def current_ability
    @current_ability ||= Incidents::Ability.new(current_user)
  end
end