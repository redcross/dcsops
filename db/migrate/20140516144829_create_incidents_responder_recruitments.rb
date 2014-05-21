class CreateIncidentsResponderRecruitments < ActiveRecord::Migration
  def change
    create_table :incidents_responder_recruitments do |t|
      t.references :incident
      t.references :person
      t.string :response
      t.references :outbound_message
      t.references :inbound_message

      t.timestamps
    end
    add_index :incidents_responder_recruitments, [:incident_id, :person_id], name: "index_responder_recruitments_incident_person"

    add_column :incidents_incidents, :recruitment_message, :string
  end
end
