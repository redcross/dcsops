# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'

arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles'

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

# Commented lines 49-63 because shift_group is an undefined method
# 
# [day, night].each do |group|
#   [sf, al, sm, so, mr, cc].each do |county|
#     Scheduler::Shift.create county: county, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_group: group, ordinal: 1, max_signups: 1, spreadsheet_ordinal: 1, dispatch_role: 1
#     Scheduler::Shift.create county: county, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], shift_group: group, ordinal: 2, max_signups: 1, spreadsheet_ordinal: 2, dispatch_role: 2
#     if county == sf
#       Scheduler::Shift.create county: county, name: 'Dispatch', abbrev: 'Disp', positions: [disp], shift_group: group, ordinal: 5, max_signups: 1, spreadsheet_ordinal: 3
#     end
#   end
# end

# Scheduler::Shift.create county: sf, name: 'Mental Health', abbrev: 'DMH', positions: [tl], shift_group: week, ordinal: 5, max_signups: 1
# Scheduler::Shift.create county: sf, name: 'Health Services', abbrev: 'DHS', positions: [tl], shift_group: month, ordinal: 6, max_signups: 1
  

# Scheduler::Shift.create county: sf, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_group: night, ordinal: 1, max_signups: 1


#load "lib/vc_importer.rb"; 
#vc = Roster::VCImporter.new; 
#vc.import_data(Roster::Chapter.first, "/Users/jlaxson/Downloads/LMSync1.xls")

# User Sample Data
# joe = Roster::Person.find_by_username('joe')
joe = Roster::Person.create
joe.chapter_id = 1
joe.primary_county_id = 1
joe.username = 'joe'
joe.password = 'test'
joe.first_name = "Joe"
joe.last_name = "Schmo"
joe.email = "joe@gmail.com"
joe.home_phone = "909-342-9568"
joe.cell_phone = "312-123-4574"
joe.alternate_phone = "717-224-1150"
joe.sms_phone = "131-234-5444"
# joe.phone_1_preference = "948-234-8592"
# joe.phone_2_preference = "203-023-9586"
# joe.phone_3_preference = "767-219-4857"
# joe.phone_4_preference = "164-283-2324"
joe.address1 = "24 N. State Street"
joe.address2 = "Apt. 001"
joe.city = "Chicago"
joe.state = "IL"
joe.zip = "60611"
joe.save!

# Incident Sample Data (chapter_id: 1, url_slug: 1, abbrev: "INS1", short_name: "Incident 1", name: "Test Incident 1")
incident1 = Incidents::Scope.create(chapter_id: 1, url_slug: 1, abbrev: "INS1", short_name: "Incident 1", name: "Test Incident 1")
incident2 = Incidents::Scope.create(chapter_id: 2, url_slug: 2, abbrev: "INS2", short_name: "Incident 2", name: "Test Incident 2")
incident3 = Incidents::Scope.create(chapter_id: 3, url_slug: 3, abbrev: "INS3", short_name: "Incident 3", name: "Test Incident 3")



