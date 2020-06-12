class AddStatusToIncident < ActiveRecord::Migration
  class Incident < ApplicationRecord
    self.table_name = 'incidents_incidents'
    has_one :dat_incident
  end
  class DatIncident < ApplicationRecord
    self.table_name = 'incidents_dat_incidents'
  end

  INVALID_TYPES = %w(invalid duplicate not_eligible_for_services)

  def up
    add_column :incidents_incidents, :status, :string, limit: 16

    say_with_time "populate status" do
      Incident.includes{dat_incident}.order(:date).find_each do |inc|
        status = if INVALID_TYPES.include? inc.incident_type
          "invalid"
        elsif inc.dat_incident or inc.ignore_incident_report
          "closed"
        else
          "open"
        end

        puts [inc.incident_number, inc.incident_type, inc.dat_incident.try(:id)||"", status].join "\t"

        inc.update_attribute :status, status
      end
    end

    change_column :incidents_incidents, :status, :string, null: false

  end

  def down
    remove_column :incidents_incidents, :status
  end
end
