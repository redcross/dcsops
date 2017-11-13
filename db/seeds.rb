# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Roster::CellCarrier.create name: 'Verizon', sms_gateway: '@vtext.com'

chapter_config_role     = Roster::Role.create(name: 'Chapter Config',     grant_name: 'chapter_config')
chapter_dat_admin_role  = Roster::Role.create(name: 'Chapter DAT Admin',  grant_name: 'chapter_dat_admin')
county_dat_admin_role   = Roster::Role.create(name: 'County DAT Admin',   grant_name: 'county_dat_admin')

arcba = Roster::Chapter.create name:'American Red Cross Bay Area', short_name:'ARCBA', code: '05503', time_zone_raw: 'America/Los_Angeles'

all = arcba.counties.create name: 'Chapter', abbrev: 'CH'
sf = arcba.counties.create name: 'San Francisco', vc_regex_raw: 'San Francisco', abbrev: 'SF'
al = arcba.counties.create name: 'Alameda', vc_regex_raw: 'Alameda', abbrev: 'AL'
sm = arcba.counties.create name: 'San Mateo', vc_regex_raw: 'San Mateo', abbrev: 'SM'
so = arcba.counties.create name: 'Solano', vc_regex_raw: 'Solano', abbrev: 'SO'
mr = arcba.counties.create name: 'Marin', vc_regex_raw: 'Marin', abbrev: 'MR'
cc = arcba.counties.create name: 'Contra Costa', vc_regex_raw: 'Contra Costa', abbrev: 'CC'

arcba.positions.create(name: 'Chapter Configuration', hidden: true).tap do |position|
  position.role_memberships.create(role: chapter_config_role)
end

arcba.positions.create(name: 'Chapter DAT Admin', hidden: true).tap do |position|
  position.role_memberships.create(role: chapter_dat_admin_role)
end

[sf, al, sm, so, mr, cc].each do |county|
  [
    arcba.positions.create(name: "DAT Administrator - #{county.name}", vc_regex_raw: "#{county.name}.*DAT Administrator$"),
    arcba.positions.create(name: "Disaster Manager - #{county.name}",  vc_regex_raw: "#{county.name}.*Disaster Manager$")
  ].each do |position|
    position.role_memberships.create(role: county_dat_admin_role)
  end
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

shift_category = Scheduler::ShiftCategory.create!

[day, night].each do |group|
  [sf, al, sm, so, mr, cc].each do |county|
    team_lead_shift = Scheduler::Shift.create!(county: county, shift_category: shift_category, name: 'Team Lead', abbrev: 'TL', positions: [tl], ordinal: 1, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 1)
    backup_lead_shift = Scheduler::Shift.create!(county: county, shift_category: shift_category, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], ordinal: 2, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 2)

    if county == sf
      dispatch_shift = Scheduler::Shift.create!(county: county, shift_category: shift_category, name: 'Dispatch', abbrev: 'Disp', positions: [disp], ordinal: 5, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 3)
    end

    [team_lead_shift, backup_lead_shift, dispatch_shift].compact.each do |created_shift|
      created_shift.shift_groups << group
      created_shift.save!
    end

    Scheduler::DispatchConfig.create!(
      name: county.name,
      county_id: county.id,
      chapter_id: county.chapter_id,
      shift_first_id: team_lead_shift.id,
      shift_second_id: backup_lead_shift.id
    )
  end
end

Scheduler::Shift.create!(county: sf, shift_category: shift_category, name: 'Mental Health', abbrev: 'DMH', positions: [tl], ordinal: 5, min_desired_signups: 0, max_signups: 1).tap do |shift|
  shift.shift_groups << week
end

Scheduler::Shift.create!(county: sf, shift_category: shift_category, name: 'Health Services', abbrev: 'DHS', positions: [tl], ordinal: 6, min_desired_signups: 0, max_signups: 1).tap do |shift|
  shift.shift_groups << month
end


#Scheduler::Shift.create county: sf, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_group: night, ordinal: 1, max_signups: 1


#load "lib/vc_importer.rb"; 
#vc = Roster::VCImporter.new; 
#vc.import_data(Roster::Chapter.first, "/Users/jlaxson/Downloads/LMSync1.xls")
#
#me = Roster::Person.find_by_last_name 'Laxson'
#me.email = 'jlaxson@mac.com'
#me.password = 'test123'
#me.save!