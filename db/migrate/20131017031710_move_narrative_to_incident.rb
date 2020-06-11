class MoveNarrativeToIncident < ActiveRecord::Migration
  class Incident < ApplicationRecord
    self.table_name = 'incidents_incidents'
  end
  class DatIncident < ApplicationRecord
    self.table_name = 'incidents_dat_incidents'
    belongs_to :incident
  end

  def change
    execute "ALTER TABLE incidents_dat_incidents ADD CONSTRAINT incidents_ref FOREIGN KEY (incident_id) REFERENCES incidents_incidents (id), ALTER incident_id SET NOT NULL"

    say_with_time "Move narratives" do
      DatIncident.find_each do |dat|
        dat.incident.update_attribute :narrative, dat.narrative
      end
    end

    remove_column :incidents_dat_incidents, :narrative
  end
end
