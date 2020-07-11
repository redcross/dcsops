class AddReasonMarkedInvalidToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :reason_marked_invalid, :string
  end
end
