class Incidents::DispatchIntakeController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Incidents::CallLog, collection_name: :call_logs, route_instance_name: :dispatch_intake
  belongs_to :region, parent_class: Incidents::Scope, finder: :find_by_url_slug!

  load_and_authorize_resource class: "Incidents::CallLog"

  before_action :authorize_dispatch_console!

  actions :new, :create, :show

  def create
    create! { resource.call_type == 'referral' ? incidents_region_dispatch_index_path(parent) : smart_resource_url }
  end

  protected

  def collection
    super.where{status == 'open'}
  end

  def create_resource obj
    super(obj).tap do |success|
      if success && obj.call_type == 'incident'
        Incidents::NewDispatchService.create obj
      end
    end
  end

  def resource_params
    [params.fetch(:incidents_call_log, {}).permit(:call_type, :call_start, :contact_name, :contact_number, :address_entry,
      :address, :city, :state, :zip, :county, :lat, :lng, :region_id, :response_territory_id,
      :incident_type, :services_requested, :num_displaced, :referral_reason).merge(dispatching_region_id: current_region.id, creator_id: current_user.id)]
  end

  def authorize_dispatch_console!
    authorize! :dispatch_console, parent
  end

end