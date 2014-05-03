class ChangeLatLngColumnsToFloat < ActiveRecord::Migration
  def change
    tables = [:roster_people, :incidents_incidents, :incidents_cas_cases, :incidents_cases, :logistics_vehicles, :partners_partners]
    tables.each do |tbl|
      change_column tbl, :lat, :float
      change_column tbl, :lng, :float
    end
  end
end
