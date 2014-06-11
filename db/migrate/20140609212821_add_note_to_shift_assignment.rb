class AddNoteToShiftAssignment < ActiveRecord::Migration
  def change
    add_column :scheduler_shift_assignments, :note, :text
  end
end
