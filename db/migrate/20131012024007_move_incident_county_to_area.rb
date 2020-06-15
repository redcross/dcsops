class MoveIncidentCountyToArea < ActiveRecord::Migration
  class Incident < ApplicationRecord
    self.table_name = "incidents_incidents"

    belongs_to :area, class_name: 'Roster::County'
  end

  def change
    add_column :incidents_incidents, :area_id, :integer
    add_column :incidents_incidents, :county, :string
    add_column :incidents_dat_incidents, :county, :string
    execute "UPDATE incidents_incidents SET area_id=county_id"

    remove_column :incidents_incidents, :county_id

    say_with_time "Populate county" do
      Incident.includes(:area).find_each do |inc|
        inc.update_attribute :county, inc.area.try(:name)
      end
    end
  end
end
