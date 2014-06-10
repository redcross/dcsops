-- Types we're interested in:
-- incident_occurred, incident_verified, assistance_requested, dispatch_received, dispatch_relayed, dat_received, dat_on_scene, dat_departed_scene

DROP VIEW IF EXISTS reporting.timeline_data CASCADE;
CREATE VIEW reporting.timeline_data AS
  WITH timeline_table AS
    (SELECT * FROM crosstab(
      $$
        SELECT incident_id, event, event_time
        FROM 
          public.incidents_event_logs el
        WHERE
          event IN ('incident_occurred', 'incident_notified', 'incident_verified', 'assistance_requested', 'dispatch_received', 'dispatch_relayed', 'dat_received', 'dat_on_scene', 'dat_departed_scene')
        ORDER BY incident_id, event
      $$,
      $$ SELECT * FROM unnest(ARRAY['incident_occurred', 'incident_notified','incident_verified', 'assistance_requested', 'dispatch_received', 'dispatch_relayed', 'dat_received', 'dat_on_scene', 'dat_departed_scene']) t $$
    ) AS tbl(incident_id integer, incident_occurred timestamp, incident_notified timestamp, incident_verified timestamp, assistance_requested timestamp, dispatch_received timestamp, dispatch_relayed timestamp, dat_received timestamp, dat_on_scene timestamp, dat_departed_scene timestamp)),
  source_table AS
    (SELECT * FROM crosstab(
      $$
        SELECT incident_id, event, source.name
        FROM 
          public.incidents_event_logs el
          INNER JOIN public.lookups source ON (source.id = el.source_id)
        WHERE
          event IN ('incident_notified', 'assistance_requested')
        ORDER BY incident_id, event
      $$,
      $$ SELECT * FROM unnest(ARRAY['incident_notified', 'assistance_requested']) t $$
    ) AS source_table(incident_id integer, incident_notified_source varchar, assistance_requested_source varchar))
  SELECT timeline_table.*,
    source_table.incident_notified_source, source_table.assistance_requested_source
  FROM 
    timeline_table LEFT JOIN source_table ON (timeline_table.incident_id = source_table.incident_id)
;