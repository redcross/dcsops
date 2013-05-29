class Roster::CountiesController < InheritedResources::Base
respond_to :html, :json
private

    # Never trust parameters from the scary internet, only allow the white list through.
    def roster_county_params
      params.require(:roster_county).permit(:name, :county_code, :fips_code, :gis_name)
    end
end
