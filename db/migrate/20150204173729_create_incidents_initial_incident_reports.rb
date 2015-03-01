class CreateIncidentsInitialIncidentReports < ActiveRecord::Migration
  def change
    create_table :incidents_initial_incident_reports do |t|
      t.references :incident, index: true
      t.references :completed_by, index: true
      t.references :approved_by, index: true
      t.boolean :budget_exceeded
      t.string :trend
      t.string :triggers, array: true
      t.integer :estimated_units
      t.integer :estimated_individuals
      t.string :expected_services, array: true
      t.boolean :significant_media
      t.boolean :safety_concerns
      t.boolean :weather_concerns

      t.timestamps
    end
  end
end
