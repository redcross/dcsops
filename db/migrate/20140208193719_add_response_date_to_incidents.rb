class AddResponseDateToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :response_date, :date

    execute "UPDATE incidents_incidents SET response_date=date"
  end
end
