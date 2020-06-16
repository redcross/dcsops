class AddShiftGroupToShiftAssignments < ActiveRecord::Migration
  class ShiftGroup < ApplicationRecord
    self.table_name = :scheduler_shift_groups
  end

  class ShiftAssignment < ApplicationRecord
    self.table_name = :scheduler_shift_assignments
  end

  class Shift < ApplicationRecord
    self.table_name = :scheduler_shifts
    belongs_to :shift_group
    has_and_belongs_to_many :shift_groups
  end

  def change
    add_column :scheduler_shift_assignments, :shift_group_id, :integer

    add_column :scheduler_shift_assignments, :new_shift_id, :integer

    create_table :scheduler_shift_groups_shifts, id: false do |t|
      t.integer :shift_id, null: false
      t.integer :shift_group_id, null:false
    end
    add_index :scheduler_shift_groups_shifts, [:shift_id, :shift_group_id], unique: true, name: "idx_scheduler_shift_groups_shifts_unique"
    execute "ALTER TABLE scheduler_shift_groups_shifts ADD CONSTRAINT shift_id_ref FOREIGN KEY (shift_id) REFERENCES scheduler_shifts(id) ON DELETE CASCADE"
    execute "ALTER TABLE scheduler_shift_groups_shifts ADD CONSTRAINT shift_group_id_ref FOREIGN KEY (shift_group_id) REFERENCES scheduler_shift_groups(id) ON DELETE CASCADE" 
    remove_index :scheduler_shift_assignments, name: :index_scheduler_shift_assignment_fields
    
    shifts_by_name = nil
    shift_replacements = Hash.new
    shift_memberships = Core::NestedHash.hash_set
    shifts_to_delete = []

    say_with_time "Group Shifts" do
      shifts = Shift.includes(:shift_group).to_a
      shifts_by_name = shifts.group_by{|sh| [sh.shift_group.chapter_id, sh.name, sh.county_id]}
      shifts_by_name.each_value do |list|
        keep_shift_id = list.map(&:id).min
        list.each do |sh|
          shift_replacements[sh.id] = {new_shift_id: keep_shift_id, shift_group_id: sh.shift_group_id}
          shift_memberships[keep_shift_id] << sh.shift_group_id
          shifts_to_delete << sh.id unless sh.id == keep_shift_id
        end
      end
    end
    say_with_time "Update Shift Assignment Group Ids" do
      shift_replacements.each do |old_shift_id, replacement|
        ShiftAssignment.where(shift_id: old_shift_id).update_all(replacement)
      end
    end

    say_with_time "Update Shift Group Memberships" do
      shift_memberships.each do |shift_id, group_ids|
        shift = Shift.find shift_id
        shift.shift_group_ids = group_ids
        shift.save
      end
    end

    say_with_time "Delete redundant shifts" do
      Shift.where(id: shifts_to_delete).destroy_all
    end

    remove_column :scheduler_shift_assignments, :shift_id
    rename_column :scheduler_shift_assignments, :new_shift_id, :shift_id

    remove_column :scheduler_shifts, :shift_group_id

    change_column :scheduler_shift_assignments, :date, :date, null: false
    change_column :scheduler_shift_assignments, :person_id, :integer, null: false
    change_column :scheduler_shift_assignments, :shift_group_id, :integer, null: false
    change_column :scheduler_shift_assignments, :shift_id, :integer, null: false

    add_index :scheduler_shift_assignments, [:date, :person_id, :shift_id, :shift_group_id], unique: true, name: :index_scheduler_shift_assignment_fields
    execute "ALTER TABLE scheduler_shift_assignments ADD CONSTRAINT shift_id_ref FOREIGN KEY (shift_id) REFERENCES scheduler_shifts(id)"
    execute "ALTER TABLE scheduler_shift_assignments ADD CONSTRAINT shift_group_id_ref FOREIGN KEY (shift_group_id) REFERENCES scheduler_shift_groups(id)" 
    execute "ALTER TABLE scheduler_shift_assignments ADD CONSTRAINT person_id_ref FOREIGN KEY (person_id) REFERENCES roster_people(id) ON DELETE CASCADE" 
  end
end
