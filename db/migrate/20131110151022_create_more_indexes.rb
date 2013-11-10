class CreateMoreIndexes < ActiveRecord::Migration
  def change
    add_index :scheduler_shift_assignments, [:date, :person_id, :shift_id], unique: true, name: 'index_scheduler_shift_assignment_fields'

    add_index :scheduler_notification_settings, :calendar_api_token, unique: true
    add_index :roster_position_memberships, [:person_id]

    add_index :named_queries, [:name, :token]
  end
end
