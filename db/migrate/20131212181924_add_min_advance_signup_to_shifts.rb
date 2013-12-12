class AddMinAdvanceSignupToShifts < ActiveRecord::Migration
  def change
    add_column :scheduler_shifts, :min_advance_signup, :integer, null: false, default: 0
  end
end
