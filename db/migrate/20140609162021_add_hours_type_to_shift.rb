class AddHoursTypeToShift < ActiveRecord::Migration
  def change
    add_column :scheduler_shifts, :vc_hours_type, :string
    add_column :scheduler_shift_assignments, :vc_hours_uploaded, :boolean, default: false
  end
end
