class Scheduler::ShiftGroupsController < Scheduler::BaseController
  respond_to :html, :json
  inherit_resources
  load_and_authorize_resource

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduler_shift_group_params
      params.require(:scheduler_shift_group).permit(:name, :period, :start_offset, :end_offset, :chapter_id)
    end
end
