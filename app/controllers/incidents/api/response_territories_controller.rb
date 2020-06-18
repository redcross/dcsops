class Incidents::Api::ResponseTerritoriesController < Incidents::BaseController
  protect_from_forgery with: :null_session
  respond_to :json

  def index
    authorize! :create, Incidents::Incident

    lookup = ResponseTerritoryLookup.new(params.require(:response_territory_lookup).permit(:city, :state, :zip, :county))
    matcher = Incidents::ResponseTerritoryMatcher.new(lookup, Incidents::ResponseTerritory.all)
    @response_territory = matcher.match_response_territory
    if @response_territory
      respond_with @response_territory
    else
      render json: {status: 'not_found'}, status: :not_found
    end
  end

  class ResponseTerritoryLookup
    attr_accessor :city, :state, :zip, :county

    def initialize attrs={}
      attrs.each do |attr, val|
        self.send "#{attr}=", val
      end
    end
  end
end