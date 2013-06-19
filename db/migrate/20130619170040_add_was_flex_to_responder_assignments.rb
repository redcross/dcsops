class AddWasFlexToResponderAssignments < ActiveRecord::Migration
  def change
    add_column :incidents_responder_assignments, :was_flex, :boolean, default: false
  end
end
