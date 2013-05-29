class Scheduler::BaseController < ApplicationController
  def current_ability
    @current_ability ||= Scheduler::Ability.new(current_user)
  end
end