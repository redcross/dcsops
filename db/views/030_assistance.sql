-- Types we're interested in:
-- incident_occurred, incident_verified, assistance_requested, dispatch_received, dispatch_relayed, dat_received, dat_on_scene, dat_departed_scene

DROP VIEW IF EXISTS reporting.assistance_data_raw CASCADE;

CREATE VIEW reporting.assistance_data_raw AS
SELECT incident_id, incident.region_id, kase.id as case_id, item.id as assistance_item_id, plitem.name, plitem.item_class, quantity, total_price
FROM incidents_case_assistance_items item
  INNER JOIN incidents_cases kase ON (item.case_id=kase.id)
  INNER JOIN incidents_incidents incident ON (kase.incident_id=incident.id)
  INNER JOIN incidents_price_list_items plitem ON (item.price_list_item_id=plitem.id)
;
