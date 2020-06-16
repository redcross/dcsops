class Api::PeopleController < Api::BaseController
  inherit_resources
  defaults resource_class: Roster::Person
  respond_to :json
  actions :index, :show

  prepend_before_action :require_user_access_token, only: :me
  load_and_authorize_resource class: resource_class, except: :me

  has_scope :deployed_to do |controller, scope, val|
    exists = Incidents::Deployment.joins(:disaster).where(disaster.dr_number: val, person_id: roster_people.id)).exists
    scope.where(exists)
  end
  has_scope :name_contains

  def me
    @person = current_access_token.account
    authorize! :read, @person
    render action: :show
  end

  protected

  def collection
    @coll ||= super.include_carriers
  end

  helper do
    def include_phones?
      params['include'] = 'phone'# && has_oauth_scope?('user_phones')
    end
  end
end