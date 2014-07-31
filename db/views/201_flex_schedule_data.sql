DROP VIEW IF EXISTS reporting.flex_schedule_data;
CREATE VIEW reporting.flex_schedule_data AS
  SELECT 
    p.chapter_id, p.id as person_id,
    p.first_name, p.last_name,

    flex.updated_at,
    flex.available_sunday_day, flex.available_sunday_night,
    flex.available_monday_day, flex.available_monday_night,
    flex.available_tuesday_day, flex.available_tuesday_night,
    flex.available_wednesday_day, flex.available_wednesday_night,
    flex.available_thursday_day, flex.available_thursday_night,
    flex.available_friday_day, flex.available_friday_night,
    flex.available_saturday_day, flex.available_saturday_night
  FROM
    scheduler_flex_schedules flex
    INNER JOIN roster_people p USING (id)
;