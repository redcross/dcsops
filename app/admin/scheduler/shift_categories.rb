ActiveAdmin.register Scheduler::ShiftCategory, as: 'Shift Category' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:shift_category).permit(:name, :show, :chapter_id, :ordinal)]
    end
  end
end
