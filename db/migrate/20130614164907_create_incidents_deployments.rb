class CreateIncidentsDeployments < ActiveRecord::Migration
  def change
    create_table :incidents_deployments do |t|
      t.references :person
      t.string :dr_name
      t.string :gap

      t.string :group
      t.string :activity
      t.string :position
      t.string :qual

      t.date :date_first_seen
      t.date :date_last_seen

      t.timestamps
    end
  end
end
