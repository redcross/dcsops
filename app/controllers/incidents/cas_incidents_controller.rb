class Incidents::CasIncidentsController < Incidents::BaseController
  inherit_resources
  load_and_authorize_resource
end