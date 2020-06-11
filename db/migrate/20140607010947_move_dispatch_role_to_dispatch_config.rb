class MoveDispatchRoleToDispatchConfig < ActiveRecord::Migration
  class Shift < ApplicationRecord
    self.table_name = :scheduler_shifts
    belongs_to :county
  end
  class County < ApplicationRecord
    self.table_name = :roster_counties
  end
  class DispatchConfig < ApplicationRecord
    self.table_name = :scheduler_dispatch_configs
  end
  def change
    add_column :scheduler_dispatch_configs, :shift_first_id, :integer
    add_column :scheduler_dispatch_configs, :shift_second_id, :integer
    add_column :scheduler_dispatch_configs, :shift_third_id, :integer
    add_column :scheduler_dispatch_configs, :shift_fourth_id, :integer
    add_column :scheduler_dispatch_configs, :chapter_id, :integer

    say_with_time "Moving dispatch order" do
      Shift.where{dispatch_role != nil}.find_each do |shift|
        config = DispatchConfig.where{county_id == shift.county_id}.first!
        config.chapter_id = shift.county.chapter_id
        case shift.dispatch_role
        when 1 then config.shift_first_id = shift.id
        when 2 then config.shift_second_id = shift.id
        when 3 then config.shift_third_id = shift.id
        when 4 then config.shift_fourth_id = shift.id
        else raise "Unknown dispatch role #{shift.dispatch_role}"
        end
        config.save!
      end
    end

    remove_column :scheduler_shifts, :dispatch_role
  end
end
