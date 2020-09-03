ActiveAdmin.register Scheduler::ShiftTime, as: 'Shift Time' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :region
  filter :name
  filter :period

  scope :all do |shift_times|
    shift_times.all
  end
  scope :enabled, default: true do |shift_times|
    shift_times.where(enabled: true)
  end

  index do
    id_column
    column :region
    column :name
    column :period
    column :start_offset
    column :end_offset
    column :enabled do |st|
      st.enabled ? status_tag("Yes") : status_tag("No")
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :region
      f.input :name
      f.input :enabled
      f.input :period, as: :assignable_select_admin
      f.input :start_offset, as: :time_offset, week: f.object.period == 'weekly'
      f.input :end_offset, as: :time_offset, week: f.object.period == 'weekly', next_period: true, midnight: true
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
      [params.fetch(resource_request_name, {}).permit(:name, :start_offset, :end_offset, :region_id, :period, :enabled, :active_sunday, :active_monday, :active_tuesday, :active_wednesday, :active_thursday, :active_friday, :active_saturday)]
    end
  end
end
