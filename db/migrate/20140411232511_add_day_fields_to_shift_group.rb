class AddDayFieldsToShiftGroup < ActiveRecord::Migration
  DAYS=%w(sunday monday tuesday wednesday thursday friday saturday)
  def change
    DAYS.each do |day|
      add_column :scheduler_shift_groups, "active_#{day}", :boolean, default: true, null: false
    end
  end
end
