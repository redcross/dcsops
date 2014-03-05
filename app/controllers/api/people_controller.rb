class Api::PeopleController < Api::BaseController
  inherit_resources
  defaults resource_class: Roster::Person
  respond_to :json
  actions :index, :show

  before_filter :require_user_access_token, only: :me
  load_and_authorize_resource class: resource_class, except: :me

  def me
    @person = current_access_token.account
    authorize! :read, @person
    render action: :show
  end
end