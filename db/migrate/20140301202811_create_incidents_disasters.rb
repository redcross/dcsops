class CreateIncidentsDisasters < ActiveRecord::Migration

  class Deployment < ApplicationRecord
    self.table_name = 'incidents_deployments'
  end

  class Disaster < ApplicationRecord
    self.table_name = 'incidents_disasters'
  end

  def change
    create_table :incidents_disasters do |t|
      t.integer :vc_incident_id
      t.string :dr_number
      t.integer :fiscal_year
      t.string :name

      t.timestamps
    end

    add_column :incidents_deployments, :disaster_id, :integer

    say_with_time "Update deployments" do
      Deployment.find_each do |dep|
        dr_number, name = dep.dr_name.split ' ', 2
        year = dr_number.split("-").last.to_i
        dr_number = dr_number.gsub "-20", "-"
        disaster = Disaster.find_or_initialize_by dr_number: dr_number
        disaster.attributes = {fiscal_year: year, name: name}
        disaster.save!
        dep.update_attribute :disaster_id, disaster.id
      end
    end
  end
end
