class Incidents::Api::TerritoriesController < Incidents::BaseController
  protect_from_forgery with: :null_session
  respond_to :json

  def index
    authorize! :create, Incidents::Incident

    lookup = TerritoryLookup.new(params.require(:territory_lookup).permit(:city, :state, :zip, :county))
    matcher = Incidents::TerritoryMatcher.new(lookup, Incidents::Territory.all)
    @territory = matcher.match_territory
    if @territory
      respond_with @territory
    else
      render json: {status: 'not_found'}, status: :not_found
    end
  end

  class TerritoryLookup
    attr_accessor :city, :state, :zip, :county

    def initialize attrs={}
      attrs.each do |attr, val|
        self.send "#{attr}=", val
      end
    end
  end
end