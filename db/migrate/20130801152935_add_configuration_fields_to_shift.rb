class AddConfigurationFieldsToShift < ActiveRecord::Migration
  class Shift < ApplicationRecord
    self.table_name = :scheduler_shifts
  end

  def change
    add_column :scheduler_shifts, :min_desired_signups, :integer
    add_column :scheduler_shifts, :ignore_county, :boolean, default: false

    say_with_time "Update min desired signups" do
      Shift.update_all min_desired_signups: 1
    end
  end
end
