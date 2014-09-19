ActiveAdmin.register Scheduler::ShiftGroup, as: 'Shift Group' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  index do
    id_column
    column :chapter
    column :name
    column :period
    column :start_offset
    column :end_offset
    actions
  end

  form do |f|
    f.inputs do
      f.input :chapter
      f.input :name
      f.input :period, as: :assignable_select_admin
      f.input :start_offset, as: :time_offset, next_day: true
      f.input :end_offset, as: :time_offset, next_day: true
    end
    f.inputs do
      f.input :active_sunday
      f.input :active_monday
      f.input :active_tuesday
      f.input :active_wednesday
      f.input :active_thursday
      f.input :active_friday
      f.input :active_saturday
    end
    f.actions
  end


  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :start_offset, :end_offset, :chapter_id, :period, :active_sunday, :active_monday, :active_tuesday, :active_wednesday, :active_thursday, :active_friday, :active_saturday)]
    end
  end
end
