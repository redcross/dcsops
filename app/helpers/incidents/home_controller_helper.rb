module Incidents::HomeControllerHelper
  include Exposure
  expose(:num_incidents_to_link) do
    Incidents::CasIncident.to_link_for_chapter(current_chapter).count
  end
end
