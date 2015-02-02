ActiveAdmin.register Scheduler::ShiftCategory, as: 'Shift Category' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :chapter
  filter :name

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :show, :chapter_id, :ordinal)]
    end
  end
end
