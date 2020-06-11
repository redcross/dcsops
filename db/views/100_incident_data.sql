DROP VIEW IF EXISTS reporting.incident_data;
CREATE VIEW reporting.incident_data AS
  SELECT 
    inc.region_id, inc.incident_number, inc.incident_type, di.incident_call_type, inc.status, inc.date,
    inc.address, inc.city, inc.state, inc.zip, inc.county, inc.lat, inc.lng,
    di.units_destroyed, di.units_major, di.units_minor, di.units_affected, di.units_unknown,
    di.units_destroyed + di.units_major + di.units_minor + di.units_affected AS units_total,
    inc.num_adults + inc.num_children as num_people, inc.num_adults, inc.num_children,
    di.num_people_injured, di.num_people_hospitalized, di.num_people_deceased, di.num_people_missing,
    inc.cas_event_number, inc.cas_event_id, inc.num_cases as num_cases_in_cas,

    di.suspicious_fire, di.size_up, di.num_exposures,
    di.injuries_black, di.injuries_red, di.injuries_yellow,
    di.where_started, di.box, di.battalion, di.num_alarms, 
    di.box_at, di.under_control_at,

    di.vacate_type, di.vacate_number,

    inc.notification_level_message, ie.name,

    td.*
  FROM
    incidents_incidents inc
    LEFT JOIN incidents_dat_incidents di ON (inc.id = di.incident_id)
    LEFT JOIN reporting.timeline_data td ON (inc.id = td.incident_id)
    LEFT JOIN incidents_notifications_events ie ON (inc.notification_level_id = ie.id)
  ORDER BY inc.id;
;
