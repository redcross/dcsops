ActiveAdmin.register Scheduler::Shift, as: 'Shift' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :shift_group
  filter :county
  filter :name
  filter :abbrev
  filter :dispatch_role
  
  scope :all, default: true do |shifts|
    shifts.includes([:shift_groups, :county]).order(:county_id, :ordinal)
  end

  index do
    #column :shift_group, sortable: "scheduler_shift_groups.start_offset"
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
    f.inputs 'Shift Groups' do
      f.input :shift_groups, as: :check_boxes, collection: Scheduler::ShiftGroup.for_chapter(f.object.county.try(:chapter))
    end
    f.inputs 'Position and County' do
      f.input :positions, as: :check_boxes, collection: f.object.county.try(:chapter).try(:positions)
      f.actions
    end
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :shift_category_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :dispatch_role, :shift_begins, :shift_ends, :signups_frozen_before, :min_desired_signups, :max_advance_signup, :min_advance_signup, :ignore_county, :position_ids => [], :shift_group_ids => [])]
    end
  end
end
