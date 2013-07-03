class AddPartnerFieldsToIncident < ActiveRecord::Migration
  def change
    add_column :incidents_incidents, :evac_partner_used, :boolean, default: false
    add_column :incidents_incidents, :hotel_partner_used, :boolean, default: false
    add_column :incidents_incidents, :shelter_partner_used, :boolean, default: false
    add_column :incidents_incidents, :feeding_partner_used, :boolean, default: false
  end
end
