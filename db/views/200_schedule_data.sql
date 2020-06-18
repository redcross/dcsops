DROP VIEW IF EXISTS reporting.schedule_data;
CREATE VIEW reporting.schedule_data AS
  SELECT 
    p.region_id, p.id as person_id,
    p.first_name, p.last_name, p.email,
    shifts.name, sa.date, 
    (sa.date::timestamp + sg.start_offset * INTERVAL '1 second') as start_time,
    (sa.date::timestamp + sg.end_offset * INTERVAL '1 second') as end_time,
    sa.created_at, ((sa.date::timestamp + sg.start_offset * INTERVAL '1 second') - sa.created_at) as advance_signup,
    (sg.end_offset - sg.start_offset) * INTERVAL '1 second' as duration
  FROM
    scheduler_shift_assignments sa
    INNER JOIN scheduler_shift_times sg ON (sa.shift_time_id=sg.id)
    INNER JOIN scheduler_shifts shifts ON (sa.shift_id=shifts.id)
    INNER JOIN roster_people p ON (sa.person_id=p.id)
;