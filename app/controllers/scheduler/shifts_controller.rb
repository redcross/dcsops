class Scheduler::ShiftsController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  load_and_authorize_resource

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      [params.require(:scheduler_shift).permit(:name, :abbrev, :shift_group_id, :max_signups, :county_id, :ordinal)]
    end
end
