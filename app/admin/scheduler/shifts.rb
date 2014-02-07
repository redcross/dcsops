ActiveAdmin.register Scheduler::Shift, as: 'Shift' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :shift_group
  filter :county
  filter :name
  filter :abbrev
  filter :dispatch_role
  
  scope :all, default: true do |shifts|
    shifts.includes([:shift_group, :county]).order(:county_id, :shift_group_id, :ordinal)
  end

  index do
    column :shift_group, sortable: "scheduler_shift_groups.start_offset"
    column :county
    column :name
    column :abbrev
    column 'Spreadsheet', :spreadsheet_ordinal
    column :ordinal
    column 'Positions' do |rec|
      rec.positions.map(&:name).join ", "
    end
    actions
  end

  form do |f|
    f.inputs 'Details'
    f.inputs 'Position and County' do
      f.input :positions, as: :check_boxes, collection: f.object.shift_group.try(:chapter).try(:positions)
      f.actions
    end
  end

  controller do
    def resource_params
      request.get? ? [] : [params.require(:shift).permit(:name, :abbrev, :shift_group_id, :shift_category_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :dispatch_role, :shift_begins, :shift_ends, :signups_frozen_before, :min_desired_signups, :max_advance_signup, :min_advance_signup, :position_ids => [])]
    end
  end
end
