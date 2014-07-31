DROP VIEW IF EXISTS reporting.position_data;
CREATE VIEW reporting.position_data AS
  SELECT 
    p.chapter_id, p.id as person_id,
    p.first_name, p.last_name,
    pos.name, pos.id as position_id
  FROM
    roster_positions pos
    INNER JOIN roster_position_memberships pm ON (pos.id=pm.position_id)
    INNER JOIN roster_people p ON (p.id=pm.person_id)
;