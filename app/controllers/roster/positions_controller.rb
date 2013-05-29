class Roster::PositionsController < InheritedResources::Base
  respond_to :html, :json

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def roster_position_params
      params.require(:roster_position).permit(:name, :vc_regex)
    end
end
