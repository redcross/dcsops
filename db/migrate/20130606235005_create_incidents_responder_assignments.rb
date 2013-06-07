class CreateIncidentsResponderAssignments < ActiveRecord::Migration
  def change
    create_table :incidents_responder_assignments do |t|
      t.references :person, index: true
      t.references :incident, index: true
      t.string :role
      t.string :response

      t.timestamps
    end
  end
end
