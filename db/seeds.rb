# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'

arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles', scheduler_flex_night_start: '64800', scheduler_flex_day_start: '21600'

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

# Add scope for Dispatch Console 
Incidents::Scope.create chapter_id: 1, url_slug: 'example_dispatch'

Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-01', shift_group_id: 4, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-07', shift_group_id: 3, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2016-02-05', shift_group_id: 1, shift_id: 1
Scheduler::ShiftAssignment.create person_id: 1, date: '2020-01-01', shift_group_id: 1, shift_id: 1

Scheduler::Shift.create name: 'test'

Scheduler:: FlexSchedule.create person_id: 1, available_sunday_day: true

# Create an example user.  Change the credentials here as desired.
Roster::Person.create(chapter: Roster::Chapter.first, email: "example@example.com", username: "example@example.com", password: "password", last_name: "Example")
me = Roster::Person.find_by_last_name 'Example'
me.password = 'test123'
me.save!
