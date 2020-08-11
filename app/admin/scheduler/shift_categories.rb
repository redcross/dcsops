ActiveAdmin.register Scheduler::ShiftCategory, as: 'Shift Category' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :region
  filter :name

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :show, :enabled, :region_id, :ordinal)]
    end
  end
end
