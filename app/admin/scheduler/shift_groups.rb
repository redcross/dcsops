ActiveAdmin.register Scheduler::ShiftGroup, as: 'Shift Group' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:shift_group).permit(:name, :start_offset, :end_offset, :chapter_id, :period)]
    end
  end
end
