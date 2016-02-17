# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'

arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles', url_slug: 'arcba', config: {"incidents_map_zoom"=>9, "incidents_geocode_bounds"=>"36.5407938301337,-124.57967382718749,39.143091210253154,-119.52596288968749", "incidents_map_center_lat"=>"37.81871654", "incidents_map_center_lng"=>"-122.19014746", "incidents_resources_tracked"=>"blankets,comfort_kits", "incidents_timeline_collect"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_timeline_mandatory"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_enabled_report_frequencies"=>"weekly,weekdays,daily", "scheduler_flex_day_start"=>"25200", "scheduler_flex_night_start"=>"68400"}

all = arcba.counties.create name: 'Chapter', abbrev: 'CH'
sf = arcba.counties.create name: 'San Francisco', vc_regex_raw: 'San Francisco', abbrev: 'SF'
al = arcba.counties.create name: 'Alameda', vc_regex_raw: 'Alameda', abbrev: 'AL'
sm = arcba.counties.create name: 'San Mateo', vc_regex_raw: 'San Mateo', abbrev: 'SM'
so = arcba.counties.create name: 'Solano', vc_regex_raw: 'Solano', abbrev: 'SO'
mr = arcba.counties.create name: 'Marin', vc_regex_raw: 'Marin', abbrev: 'MR'
cc = arcba.counties.create name: 'Contra Costa', vc_regex_raw: 'Contra Costa', abbrev: 'CC'

arcba.positions.create name: 'Chapter Configuration', hidden: true
arcba.positions.create name: 'Chapter DAT Admin', hidden: true
[sf, al, sm, so, mr, cc].each do |county|
  arcba.positions.create name: "DAT Administrator - #{county.name}", vc_regex_raw: "#{county.name}.*DAT Administrator$"
  arcba.positions.create name: "Disaster Manager - #{county.name}", vc_regex_raw: "#{county.name}.*Disaster Manager$"
end

tl = arcba.positions.create name: 'DAT Team Lead', vc_regex_raw: 'Team Lead$'
tech = arcba.positions.create name: 'DAT Technician', vc_regex_raw: 'Technician$'
trainee = arcba.positions.create name: 'DAT Trainee', vc_regex_raw: 'Trainee$'
disp = arcba.positions.create name: 'DAT Dispatcher', vc_regex_raw: 'Dispatch$'
arcba.positions.create name: 'ERV Driver', vc_regex_raw: '^ERV$'
arcba.positions.create name: 'Bay Responder Driver', vc_regex_raw: '^Bay Responder$'
arcba.positions.create name: 'Forklift', vc_regex_raw: '^Forklift'
arcba.positions.create name: 'Tow Shelter Trailer', vc_regex_raw: '^Tow Shelter Trailer$'
arcba.positions.create name: 'Chapter Vehicle', vc_regex_raw: '^Chapter Vehicle'
arcba.positions.create name: 'CAC Activator', vc_regex_raw: '^CAC Activator'
arcba.positions.create name: 'DSHR', vc_regex_raw: 'DSHR'

day = Scheduler::ShiftGroup.create chapter: arcba, name: 'Day', start_offset: 25200, end_offset: 68400, period: 'daily'
night = Scheduler::ShiftGroup.create chapter: arcba, name: 'Night', start_offset: 68400, end_offset: 111600, period: 'daily'
week = Scheduler::ShiftGroup.create chapter: arcba, name: 'Weekly', start_offset: 0, end_offset: 7.days, period: 'weekly'
month = Scheduler::ShiftGroup.create chapter: arcba, name: 'Monthly', start_offset: 0, end_offset: 31, period: 'monthly'

[day, night].each do |group|
  [sf, al, sm, so, mr, cc].each do |county|
    Scheduler::Shift.create county: county, name: 'Team Lead', abbrev: 'TL', positions: [tl], ordinal: 1, max_signups: 1, spreadsheet_ordinal: 1
    Scheduler::Shift.create county: county, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], ordinal: 2, max_signups: 1, spreadsheet_ordinal: 2
    if county == sf
      Scheduler::Shift.create county: county, name: 'Dispatch', abbrev: 'Disp', positions: [disp], ordinal: 5, max_signups: 1, spreadsheet_ordinal: 3
    end
  end
end

Scheduler::Shift.create county: sf, name: 'Mental Health', abbrev: 'DMH', positions: [tl], ordinal: 5, max_signups: 1
Scheduler::Shift.create county: sf, name: 'Health Services', abbrev: 'DHS', positions: [tl], ordinal: 6, max_signups: 1

# add initial vehicles
# see and alter the allowable vehicle categories in app/models/logistics/vehicle.rb
Logistics::Vehicle.create chapter_id: 1, name: 'pick-up truck', category: 'suv'
Logistics::Vehicle.create chapter_id: 1, name: 'ambulance', category: 'erv'

# Add all links to front page:

HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Volunteer Connection', url: 'placeholder', group: 'Other Tools', group_ordinal: 1, ordinal: 1, icon: 'fa fa-2x fa-home'

HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Example Chapter Dispatch Console', url: '/incidents/example_dispatch', group: 'Dispatch', group_ordinal: 2, ordinal: 1, icon: 'fa fa-2x fa-check-square-o'
HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Dispatcher Updates', url: 'placeholder', group: 'Dispatch', group_ordinal: 2, ordinal: 2, icon: 'fa fa-2x fa-exclamation-circle'
HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Fire Department Contacts', url: 'placeholder', group: 'Dispatch', group_ordinal: 2, ordinal: 3, icon: 'fa fa-2x fa-phone'
HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Cas 2.0', url: 'placeholder', group: 'Dispatch', group_ordinal: 2, ordinal: 4, icon: 'fa fa-2x fa-credit-card'
HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Dispatch Mini-Manual', url: 'placeholder', group: 'Dispatch', group_ordinal: 2, ordinal: 5, icon: 'fa fa-2x fa-book'
HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Chicago and Northwest Illinois Region Map', url: 'placeholder', group: 'Dispatch', group_ordinal: 2, ordinal: 6, icon: 'fa fa-2x fa-map-marker'

HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'Response Handbook', url: 'placeholder', group: 'Admin / Staff Back-Up', group_ordinal: 3, ordinal: 1, icon: 'fa fa-2x fa-list-alt'

HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'SitCell Common Operating Picture', url: 'placeholder', group: 'SitCell', group_ordinal: 4, ordinal: 1, icon: 'fa fa-2x fa-compass'

HomepageLink.create chapter_id: Roster::Chapter.first,  name: 'DCSOps Training Videos', url: 'placeholder', group: 'Help', group_ordinal: 5, ordinal: 1, icon: 'fa fa-2x fa-youtube'
# trying to make an admin person:

Roster::CountyMembership.create county_id: 1, person_id: 1, persistent: true

# all the roles I can find mentioned:
inc_ad = Roster::Role.create name: 'incidents_admin', grant_name: 'incidents_admin'
config = Roster::Role.create name: 'chapter_config', grant_name: 'chapter_config'
chap_ad = Roster::Role.create name: 'chapter_admin', grant_name: 'chapter_admin'
dat_ad = Roster::Role.create name: 'chapter_dat_admin', grant_name: 'chapter_dat_admin'
active = Roster::Role.create name: 'always_active', grant_name: 'always_active'
sched = Roster::Role.create name: 'chapter_scheduler', grant_name: 'chapter_scheduler'
disp = Roster::Role.create name: 'dispatch_console', grant_name: 'dispatch_console'
cre = Roster::Role.create name: 'create_incident', grant_name: 'create_incident'
sub = Roster::Role.create name: 'submit_incident_report', grant_name: 'submit_incident_report'
cas = Roster::Role.create name: 'cas_admin', grant_name: 'cas_admin'
det = Roster::Role.create name: 'incident_details', grant_name: 'incident_details'
cas_det = Roster::Role.create name: 'cas_details', grant_name: 'cas_details'
resp = Roster::Role.create name: 'see_responses', grant_name: 'see_responses'
iir = Roster::Role.create name: 'approve_iir', grant_name: 'approve_iir'

# assign all these roles to the first position: "Chapter Configuration"
[inc_ad, config, chap_ad, dat_ad, active, sched, disp, cre, sub, cas, det, cas_det, resp, iir].each do |role|
  role_id = role.id
  Roster::RoleMembership.create role_id: role_id, position_id: 1
  Roster::RoleMembership.create role_id: role_id, position_id: 1
end

# Add admin user (created below) to the "Chapter Configuration"
# position, thus giving that user all the permissions listed in the
# roles above
Roster::PositionMembership.create position_id: 1, person_id: 1, persistent: true

# Add scope for Dispatch Console 
Incidents::Scope.create chapter_id: 1, url_slug: 'example_dispatch'
# Add scope for chapter incidents
Incidents::Scope.create chapter_id: 1, url_slug: 'arcba', short_name: 'Bay Area'
# Create some incidents
Incidents::NumberSequence.create name: 'test', current_year: '2016', current_number: '0', format: '%<fy_short>02d-%<number>04d'
Incidents::Territory.create chapter_id: 1, name: 'test_territory', enabled: true

# incident numbers must match regex: \A\w*\d{2}-\d{3,}\z
incident = Incidents::Incident.create(chapter_id: 1, incident_number: '16-001', date: '2016-01-05', num_adults:2, num_children: 3, address: '3500 S Western Ave', city: 'Chicago', state: 'IL', zip: '60609', lat: '41.830402', lng: '-87.685342', status: 'open', territory_id: 1)
incident.save!
bay_incident = Incidents::Incident.create(chapter_id: 1, incident_number: '16-002', date: '2016-02-10', num_adults:2, num_children: 3, address: '1 Dr Carlton B Goodlett Pl', city: 'San Francisco', state: 'CA', zip: '94102', lat: '37.779361', lng: '-122.419264', status: 'open', territory_id: 1)
bay_incident.save!


Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-01', shift_group_id: 4, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-07', shift_group_id: 3, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-05', shift_group_id: 1, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2020-01-01', shift_group_id: 1, shift_id: 1

Scheduler::Shift.create name: 'test'

Scheduler:: FlexSchedule.create person_id: 1, available_sunday_day: true

# Create an example admin user.  Change the credentials here as desired.
Roster::Person.create(chapter: Roster::Chapter.first, email: "example@example.com", username: "admin", password: "password", last_name: "Admin_User", first_name: 'TestUser', vc_is_active: 1)
me = Roster::Person.find_by_last_name 'Admin_User'
me.password = 'test123'
me.save!
# Create an example non-admin user.  Change the credentials here as desired.
Roster::Person.create(chapter: Roster::Chapter.first, email: "example@example.com", username: "example_user", password: "password", last_name: "Example", first_name: 'TestUser', vc_is_active: 1)
me = Roster::Person.find_by_last_name 'Example'
me.password = 'test123'
me.save!

# Add some sample responders.

['Mary', 'Joe', 'Jane', 'Ashley', 'Tom'].each do |name|
  Roster::Person.create(chapter: Roster::Chapter.first, username: "example_user", last_name: "Example", first_name: name, vc_is_active: 1)
end
