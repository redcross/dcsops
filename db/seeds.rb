# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'
Roster::CellCarrier.create name: 'AT&T', sms_gateway: '@txt.att.net'
Roster::CellCarrier.create name: 'Boost Mobile', sms_gateway: '@myboostmobile.com'
Roster::CellCarrier.create name: 'Alltel', sms_gateway: '@message.alltel.com'
Roster::CellCarrier.create name: 'T-Mobile', sms_gateway: '@tmomail.net'
Roster::CellCarrier.create name: 'US Cellular', sms_gateway: '@email.uscc.net'
Roster::CellCarrier.create name: 'Virgin Mobile', sms_gateway: '@vmobl.com'
Roster::CellCarrier.create name: 'Sprint', sms_gateway: '@messaging.sprintpcs.com'



arcil = Roster::Chapter.create name:'American Red Cross Illinois Area', short_name:'ARCIL', code: '05503', time_zone_raw: 'America/Chicago', url_slug: 'arcil', config: {"incidents_map_zoom"=>7, "incidents_geocode_bounds"=>"42.363599, -90.675103,38.639380, -87.829644", "incidents_map_center_lat"=>"40.435855", "incidents_map_center_lng"=>"-89.496991", "incidents_resources_tracked"=>"blankets,comfort_kits", "incidents_timeline_collect"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_timeline_mandatory"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_enabled_report_frequencies"=>"weekly,weekdays,daily", "scheduler_flex_day_start"=>"25200", "scheduler_flex_night_start"=>"68400", "incidents_enable_dispatch_console"=>true}
arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles', url_slug: 'arcba', config: {"incidents_map_zoom"=>9, "incidents_geocode_bounds"=>"36.5407938301337,-124.57967382718749,39.143091210253154,-119.52596288968749", "incidents_map_center_lat"=>"37.81871654", "incidents_map_center_lng"=>"-122.19014746", "incidents_resources_tracked"=>"blankets,comfort_kits", "incidents_timeline_collect"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_timeline_mandatory"=>"dat_received,dat_on_scene,dat_departed_scene", "incidents_enabled_report_frequencies"=>"weekly,weekdays,daily", "scheduler_flex_day_start"=>"25200", "scheduler_flex_night_start"=>"68400", "incidents_enable_dispatch_console"=>true}

# Create an example admin user.  Change the credentials here as desired.
Roster::Person.create(chapter: Roster::Chapter.first, email: "example@example.com", username: "admin", password: "password", last_name: "Admin_User", first_name: 'TestUser', vc_is_active: 1)
admin = Roster::Person.find_by_last_name 'Admin_User'
admin.password = 'test123'
admin.save!
# Create an example non-admin user.  Change the credentials here as desired.
Roster::Person.create(chapter: Roster::Chapter.first, email: "example@example.com", username: "example_user", password: "password", last_name: "Example_User", first_name: 'TestUser', vc_is_active: 1)
example = Roster::Person.find_by_last_name 'Example_User'
example.password = 'test123'
example.save!


#foooooo

all = arcba.counties.create name: 'Chapter', abbrev: 'CH'
#sf = arcba.counties.create name: 'San Francisco', vc_regex_raw: 'San Francisco', abbrev: 'SF'
#al = arcba.counties.create name: 'Alameda', vc_regex_raw: 'Alameda', abbrev: 'AL'
#sm = arcba.counties.create name: 'San Mateo', vc_regex_raw: 'San Mateo', abbrev: 'SM'
so = arcba.counties.create name: 'Solano', vc_regex_raw: 'Solano', abbrev: 'SO'
mr = arcba.counties.create name: 'Marin', vc_regex_raw: 'Marin', abbrev: 'MR'
cc = arcba.counties.create name: 'Contra Costa', vc_regex_raw: 'Contra Costa', abbrev: 'CC'

sf = arcil.counties.create name: 'Greater Cook', vc_regex_raw: 'Greater Cook', abbrev: 'CK'
al = arcil.counties.create name: 'Chicago', vc_regex_raw: 'Chicago', abbrev: 'CH'
sm = arcil.counties.create name: 'SW Suburbs', vc_regex_raw: 'SW Suburbs', abbrev: 'SW'



chap_config = arcil.positions.create name: 'Chapter Configuration', hidden: true
arcil.positions.create name: 'Chapter DAT Admin', hidden: true
[sf, al, sm, so, mr, cc].each do |county|
  arcil.positions.create name: "DAT Administrator - #{county.name}", vc_regex_raw: "#{county.name}.*DAT Administrator$"
  arcil.positions.create name: "Disaster Manager - #{county.name}", vc_regex_raw: "#{county.name}.*Disaster Manager$"
end

tl = arcil.positions.create name: 'DAT Team Lead', vc_regex_raw: 'Team Lead$'
tech = arcil.positions.create name: 'DAT Technician', vc_regex_raw: 'Technician$'
trainee = arcil.positions.create name: 'DAT Trainee', vc_regex_raw: 'Trainee$'
disp = arcil.positions.create name: 'DAT Dispatcher', vc_regex_raw: 'Dispatch$'
dispatch = arcil.positions.create name: 'Dispatch', vc_regex_raw: 'disp'
arcil.positions.create name: 'ERV Driver', vc_regex_raw: '^ERV$'
arcil.positions.create name: 'Bay Responder Driver', vc_regex_raw: '^Bay Responder$'
arcil.positions.create name: 'Forklift', vc_regex_raw: '^Forklift'
arcil.positions.create name: 'Tow Shelter Trailer', vc_regex_raw: '^Tow Shelter Trailer$'
arcil.positions.create name: 'Chapter Vehicle', vc_regex_raw: '^Chapter Vehicle'
arcil.positions.create name: 'CAC Activator', vc_regex_raw: '^CAC Activator'
arcil.positions.create name: 'DSHR', vc_regex_raw: 'DSHR'
calmgr = arcil.positions.create name: 'Calendar Manager', vc_regex_raw: 'CalMgr'
chapter_admin = arcil.positions.create name: 'Chapter Admin'
scheduler = arcil.positions.create name: 'Scheduling Administrator'
admin_pos = arcil.positions.create name: 'Admin'
cas_admin = arcil.positions.create name: 'CAS Admin'
# all roles to certain positions

# calendar manager
dat_ad = Roster::Role.create name: 'Chapter DAT Admin', grant_name: 'chapter_dat_admin'
Roster::RoleMembership.create role_id: dat_ad.id, position_id: calmgr.id
# chapter admin
chap_ad = Roster::Role.create name: 'Chapter Admin', grant_name: 'chapter_admin'
county_roster = Roster::Role.create name: 'County Roster', grant_name: 'county_roster'
resp = Roster::Role.create name: 'See Responses', grant_name: 'see_responses'
[chap_ad, county_roster, resp].each do |role|
  Roster::RoleMembership.create role_id: role.id, position_id: chapter_admin.id
end
# chapter configuration
config = Roster::Role.create name: 'Chapter Config', grant_name: 'chapter_config'
Roster::RoleMembership.create role_id: config.id, position_id: chap_config.id
# dispatch
cre = Roster::Role.create name: 'Create Incident', grant_name: 'create_incident'
sub = Roster::Role.create name: 'Submit Incident Report', grant_name: 'submit_incident_report'
det = Roster::Role.create name: 'Incident Details', grant_name: 'incident_details'
cas_det = Roster::Role.create name: 'CAS Details', grant_name: 'cas_details'
disp_role = Roster::Role.create name: 'Dispatch Console', grant_name: 'dispatch_console'
###homepage link?
[cre, sub, det, cas_det, disp_role].each do |role|
  Roster::RoleMembership.create role_id: role.id, position_id: dispatch.id
end
# scheduling administrator
sched = Roster::Role.create name: 'Chapter Scheduler', grant_name: 'chapter_scheduler'
[sched, dat_ad].each do |role|
  Roster::RoleMembership.create role_id: role.id, position_id: scheduler.id
end
# admin
inc_ad = Roster::Role.create name: 'Incidents Admin', grant_name: 'incidents_admin'
[cre, sched, det, cas_det, inc_ad].each do |role|
  Roster::RoleMembership.create role_id: role.id, position_id: admin_pos.id
end

# Making up the CAS admin position to have these roles
cas = Roster::Role.create name: 'CAS Admin', grant_name: 'cas_admin'
active = Roster::Role.create name: 'Always Active', grant_name: 'always_active'
iir = Roster::Role.create name: 'Approve IIR', grant_name: 'approve_iir'
[cas, active, iir].each do |role|
  Roster::RoleMembership.create role_id: role.id, position_id: cas_admin.id
end


# Add admin user (created below) to the positions with roles, thus
# giving that user all the permissions listed in the roles above
#
# Also give user the positions associated with shifts, below
[calmgr, chapter_admin,  chap_config, dispatch, scheduler, admin_pos, cas_admin, tl, disp].each do |position|
  Roster::PositionMembership.create position_id: position.id, person_id: 1, persistent: true
end

# give example user some positions, too
[dispatch, tl, disp].each do | position|
  Roster::PositionMembership.create position_id: position.id, person_id: example.id, persistent: true
end




day = Scheduler::ShiftGroup.create chapter: arcil, name: 'Day', start_offset: 25200, end_offset: 68400, period: 'daily'
night = Scheduler::ShiftGroup.create chapter: arcil, name: 'Night', start_offset: 68400, end_offset: 111600, period: 'daily'
#week = Scheduler::ShiftGroup.create chapter: arcil, name: 'Weekly', start_offset: 0, end_offset: 7.days, period: 'weekly'
month = Scheduler::ShiftGroup.create chapter: arcil, name: 'Monthly', start_offset: 0, end_offset: 31, period: 'monthly'

Scheduler::ShiftCategory.create chapter: arcil, name: 'Response', show: true

  [sf, al, sm, so, mr, cc].each do |county|
    team_lead_shift = Scheduler::Shift.create county: county, name: 'Team Lead', abbrev: 'TL', positions: [tl], ordinal: 1, max_signups: 1, spreadsheet_ordinal: 1, shift_category: Scheduler::ShiftCategory.first, min_desired_signups: 1
    btl_shift = Scheduler::Shift.create county: county, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], ordinal: 2, max_signups: 1, spreadsheet_ordinal: 2, shift_category: Scheduler::ShiftCategory.first, min_desired_signups: 1
    [team_lead_shift, btl_shift].each do |shift|
      shift.shift_groups = [day, night]
    end
    if county == sf
      disp_shift = Scheduler::Shift.create county: county, name: 'Dispatch', abbrev: 'Disp', positions: [disp], ordinal: 5, max_signups: 1, spreadsheet_ordinal: 3, shift_category: Scheduler::ShiftCategory.first, min_desired_signups: 1
      disp_shift.shift_groups = [day, night]
    end
  end

mental_health_shift = Scheduler::Shift.create county: sf, name: 'Mental Health', abbrev: 'DMH', positions: [tl], ordinal: 5, max_signups: 1, shift_category: Scheduler::ShiftCategory.first, min_desired_signups: 1
health_services_shift = Scheduler::Shift.create county: sf, name: 'Health Services', abbrev: 'DHS', positions: [tl], ordinal: 6, max_signups: 1, shift_category: Scheduler::ShiftCategory.first, min_desired_signups: 1

# assign shifts to groups
[mental_health_shift, health_services_shift].each do |shift|
  shift.shift_groups = [day]
  shift.save
end

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

Roster::CountyMembership.create county_id: so.id, person_id: admin.id, persistent: true
Roster::CountyMembership.create county_id: sf.id, person_id: admin.id, persistent: true
Roster::CountyMembership.create county_id: mr.id, person_id: admin.id, persistent: true
Roster::CountyMembership.create county_id: cc.id, person_id: admin.id, persistent: true
Roster::CountyMembership.create county_id: al.id, person_id: admin.id, persistent: true
Roster::CountyMembership.create county_id: sm.id, person_id: admin.id, persistent: true

Roster::CountyMembership.create county_id: sf.id, person_id: example.id, persistent: true
Roster::CountyMembership.create county_id: al.id, person_id: example.id, persistent: true


# Add scope for Dispatch Console 
Incidents::Scope.create chapter_id: 1, url_slug: 'example_dispatch'
# Add scope for chapter incidents
Incidents::Scope.create chapter_id: 1, url_slug: 'arcil', short_name: 'Illinois Area'
# Create some incidents
Incidents::NumberSequence.create name: 'test', current_year: '2016', current_number: '0', format: '%<fy_short>02d-%<number>04d'
backup_person = Roster::Person.create(chapter: Roster::Chapter.first, last_name: "Example", first_name: "Backup", vc_is_active: 1)
dc = Scheduler::DispatchConfig.create chapter: Roster::Chapter.first, backup_first: backup_person
Incidents::Territory.create chapter_id: 1, name: 'test_territory', enabled: true, dispatch_config: dc

# incident numbers must match regex: \A\w*\d{2}-\d{3,}\z
Incidents::Incident.create(chapter_id: 1, incident_number: '16-001', date: '2016-02-10', num_adults: 2, num_children: 3, address: '3500 S Western Ave', city: 'Chicago', state: 'IL', zip: '60609', lat: '41.830146', lng: '-87.685041', status: 'open', territory_id: 1)
Incidents::Incident.create(chapter_id: 1, incident_number: '16-002', date: '2016-02-15', num_adults: 2, num_children: 3, address: '1001 S 2nd Street', city: 'Springfield', state: 'IL', zip: '62707', lat: '39.790943', lng: '-89.653209', status: 'open', territory_id: 1)
Incidents::Incident.create(chapter_id: 1, incident_number: '16-003', date: '2016-02-18', num_adults: 2, num_children: 3, address: '10 E Willow St', city: 'Normal', state: 'IL', zip: '61761', lat: '40.513898', lng: '-88.984202', status: 'open', territory_id: 1)

Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-01', shift_group_id: 4, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-07', shift_group_id: 2, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-05', shift_group_id: 1, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2020-01-01', shift_group_id: 1, shift_id: 1

Scheduler::Shift.create name: 'test'

Scheduler:: FlexSchedule.create person_id: 1, available_sunday_day: true

# Add some sample responders.

['Ashley', 'Destiny', 'Imani', 'Jayden', 'Jane', 'John', 'Lucia', 'Mateo', 'Tom'].each do |name|
  Roster::Person.create(chapter: Roster::Chapter.first, last_name: "Example", first_name: name, vc_is_active: 1)
end
