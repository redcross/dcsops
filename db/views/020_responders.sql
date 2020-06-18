DROP VIEW IF EXISTS reporting.responder_data CASCADE;
CREATE VIEW reporting.responder_data AS
SELECT incident_id, incident.region_id, incident.incident_number,
  role, person_id, CONCAT(person.first_name, ' ', person.last_name)
FROM incidents_responder_assignments ra
  INNER JOIN incidents_incidents incident ON (ra.incident_id=incident.id)
  INNER JOIN roster_people person ON (ra.person_id=person.id);
