data_loc = ARGV[0]

incident_columns = [
  ["id",],
  ["region", ->(i){i.region.name if i.region}],
  ["incident_number",],
  ["incident_type",],
  ["cas_event_number",],
  ["date",],
  ["num_adults",],
  ["num_children",],
  ["num_families",],
  ["num_cases",],
  ["incident_description",],
  ["narrative_brief",],
  ["narrative",],
  ["address",],
  ["cross_street",],
  ["neighborhood",],
  ["city",],
  ["state",],
  ["zip",],
  ["lat",],
  ["lng",],
  ["last_idat_sync",],
  ["last_no_incident_warning",],
  ["ignore_incident_report",],
  ["evac_partner_used",],
  ["hotel_partner_used",],
  ["shelter_partner_used",],
  ["feeding_partner_used",],
  ["shift_territory", ->(i){i.shift_territory.name if i.shift_territory}],
  ["county",],
  ["status",],
  ["response_date",],
  ["notification_level", ->(i){i.notification_level.name if i.notification_level}],
  ["notification_level_message",],
  ["recruitment_message",],
  ["address_directly_entered",],
  ["response_territory", ->(i){i.response_territory.name if i.response_territory}],
  ["current_dispatch_contact", ->(i){i.current_dispatch_contact.full_name if i.current_dispatch_contact}],
  ["dispatch_contact_due_at",],
  ["reason_marked_invalid",],
  ["rccare_event_id",],
]

dat_incident_columns = [
  ["incident_call_type",],
  ["verified_by",],
  ["num_people_injured",],
  ["num_people_hospitalized",],
  ["num_people_deceased",],
  ["cross_street",],
  ["units_affected",],
  ["units_minor",],
  ["units_major",],
  ["units_destroyed",],
  ["services",],
  ["structure_type",],
  ["completed_by", ->(i){i.completed_by.full_name if i.completed_by}],
  ["languages",],
  ["resources_hstore",],
  ["num_first_responders",],
  ["suspicious_fire",],
  ["injuries_black",],
  ["injuries_red",],
  ["injuries_yellow",],
  ["where_started",],
  ["under_control_at",],
  ["box",],
  ["box_at",],
  ["battalion",],
  ["num_alarms",],
  ["size_up",],
  ["num_exposures",],
  ["vacate_type",],
  ["vacate_number",],
  ["num_people_missing",],
  ["hazardous_materials",],
  ["units_unknown",],
  ["resources",],
]

Roster::Region.all.each{|region|
#Roster::Region.where(name: "Illinois").each{|region|
  CSV.open(data_loc + "/" + region.name + ".csv", "w") do |csv|
    csv << incident_columns.map(&:first) + dat_incident_columns.map(&:first)
    region.incidents.order(:date, :id).each{|incident|
      data = incident_columns.map{|col|
        if col.size == 1
          incident[col[0]]
        else
          col[1].call incident
        end
      }

      if !incident.dat_incident.nil?
        data = data + dat_incident_columns.map{|col|
          if col.size == 1
            incident.dat_incident[col[0]]
          else
            col[1].call incident.dat_incident
          end
        }
      end
      csv << data
    }
  end
}
