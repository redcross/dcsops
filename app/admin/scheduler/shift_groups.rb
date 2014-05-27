ActiveAdmin.register Scheduler::ShiftGroup, as: 'Shift Group' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :start_offset, :end_offset, :chapter_id, :period, :active_sunday, :active_monday, :active_tuesday, :active_wednesday, :active_thursday, :active_friday, :active_saturday)]
    end
  end
end
