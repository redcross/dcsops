class Incidents::DispatchIntakeController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Incidents::CallLog, collection_name: :call_logs, route_instance_name: :dispatch_intake
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!

  actions :new, :create

  def create
    create! { incidents_chapter_dispatch_index_path(parent) }
  end

  protected

  def collection
    super.where{status == 'open'}
  end

  def create_resource obj
    obj.creator = current_user
    if super(obj) && obj.call_type == 'incident'
      Incidents::NewDispatchService.create obj
    end
  end

  def resource_params
    [params.fetch(:incidents_call_log, {}).permit(:call_type, :call_start, :contact_name, :contact_number, :address_entry,
      :address, :city, :state, :zip, :county, :lat, :lng, :chapter_id, :territory_id,
      :incident_type, :services_requested, :num_displaced, :referral_reason)]
  end

#  def scope
#    @scope ||= Incidents::Scope.for_chapter(resource.chapter_id)
#  end
#  helper_method :scope
#
#  def dispatch_obj
#    @dispatch_obj ||= Dispatch.new
#  end
#  helper_method :dispatch_obj

#  class Dispatch
#    extend ActiveModel::Naming
#
#    attr_accessor :chapter, :dispatching_chapter
#    attr_accessor :incident_id, :call_type
#
#    attr_accessor :contact_name, :contact_number
#    attr_accessor :address, :city, :state, :zip, :lat, :lng
#
#    attr_accessor :incident_type
#    attr_accessor :services_requested, :num_displaced
#
#    attr_accessor :referral_reason
#
#    def humanized_valid_incident_types
#      i = Incidents::Incident.new
#      i.humanized_valid_incident_types
#    end
#  end
end