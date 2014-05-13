class AddStatusFieldsToResponderAssignment < ActiveRecord::Migration
  def change
    add_column :incidents_responder_assignments, :driving_distance, :float

    add_column :incidents_responder_assignments, :dispatched_at, :timestamp
    add_column :incidents_responder_assignments, :on_scene_at, :timestamp
    add_column :incidents_responder_assignments, :departed_scene_at, :timestamp
  end
end
