class CreateSchedulerFlexSchedules < ActiveRecord::Migration
  def change
    create_table :scheduler_flex_schedules do |t|
      t.references :person, index: true

      %i(sunday monday tuesday wednesday thursday friday saturday).each do |day|
        %i(day night).each do |time|
          t.boolean "available_#{day}_#{time}"
        end
      end

      t.timestamps
    end
  end
end
