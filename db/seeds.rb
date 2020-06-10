# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

unless Rails.env.development? || ENV['ALLOW_DATA_SEEDING'].to_i == 1
  abort 'Data seeding disabled in this environment. Run again with ALLOW_DATA_SEEDING=1 to force.'
end

cell_carrier = Roster::CellCarrier.create! name: 'Verizon', sms_gateway: '@vtext.com'

region_config_capability     = Roster::Capability.create!(name: 'Region Config',     grant_name: 'region_config')
region_dat_admin_capability  = Roster::Capability.create!(name: 'Region DAT Admin',  grant_name: 'region_dat_admin')
shift_territory_dat_admin_capability   = Roster::Capability.create!(name: 'Shift Territory DAT Admin',   grant_name: 'shift_territory_dat_admin')

arcba = Roster::Region.create! name:'American Red Cross Bay Area', short_name:'ARCBA', url_slug: 'arcba', code: '05503', time_zone_raw: 'America/Los_Angeles', scheduler_flex_day_start: 28800, scheduler_flex_night_start: 72000

all = arcba.shift_territories.create! name: 'Region', abbrev: 'CH'
sf = arcba.shift_territories.create! name: 'San Francisco', vc_regex_raw: 'San Francisco', abbrev: 'SF'
al = arcba.shift_territories.create! name: 'Alameda', vc_regex_raw: 'Alameda', abbrev: 'AL'
sm = arcba.shift_territories.create! name: 'San Mateo', vc_regex_raw: 'San Mateo', abbrev: 'SM'
so = arcba.shift_territories.create! name: 'Solano', vc_regex_raw: 'Solano', abbrev: 'SO'
mr = arcba.shift_territories.create! name: 'Marin', vc_regex_raw: 'Marin', abbrev: 'MR'
cc = arcba.shift_territories.create! name: 'Contra Costa', vc_regex_raw: 'Contra Costa', abbrev: 'CC'

region_config_position = arcba.positions.create!(name: 'Region Configuration', hidden: true).tap do |position|
  position.capability_memberships.create!(capability: region_config_capability)
end

region_dat_admin_position = arcba.positions.create!(name: 'Region DAT Admin', hidden: true).tap do |position|
  position.capability_memberships.create!(capability: region_dat_admin_capability)
end

shift_territory_dat_admin_position = nil

[sf, al, sm, so, mr, cc].each do |shift_territory|
  positions = [
    arcba.positions.create!(name: "DAT Administrator - #{shift_territory.name}", vc_regex_raw: "#{shift_territory.name}.*DAT Administrator$"),
    arcba.positions.create!(name: "Disaster Manager - #{shift_territory.name}",  vc_regex_raw: "#{shift_territory.name}.*Disaster Manager$")
  ].each do |position|
    position.capability_memberships.create!(capability: shift_territory_dat_admin_capability)
  end
  shift_territory_dat_admin_position = positions.first if shift_territory == sf
end

tl = arcba.positions.create! name: 'DAT Team Lead', vc_regex_raw: 'Team Lead$'
tech = arcba.positions.create! name: 'DAT Technician', vc_regex_raw: 'Technician$'
trainee = arcba.positions.create! name: 'DAT Trainee', vc_regex_raw: 'Trainee$'
disp = arcba.positions.create! name: 'DAT Dispatcher', vc_regex_raw: 'Dispatch$'
arcba.positions.create! name: 'ERV Driver', vc_regex_raw: '^ERV$'
arcba.positions.create! name: 'Bay Responder Driver', vc_regex_raw: '^Bay Responder$'
arcba.positions.create! name: 'Forklift', vc_regex_raw: '^Forklift'
arcba.positions.create! name: 'Tow Shelter Trailer', vc_regex_raw: '^Tow Shelter Trailer$'
arcba.positions.create! name: 'Region Vehicle', vc_regex_raw: '^Region Vehicle'
arcba.positions.create! name: 'CAC Activator', vc_regex_raw: '^CAC Activator'
arcba.positions.create! name: 'DSHR', vc_regex_raw: 'DSHR'

day = Scheduler::ShiftTime.create! region: arcba, name: 'Day', start_offset: 25200, end_offset: 68400, period: 'daily'
night = Scheduler::ShiftTime.create! region: arcba, name: 'Night', start_offset: 68400, end_offset: 111600, period: 'daily'
week = Scheduler::ShiftTime.create! region: arcba, name: 'Weekly', start_offset: 0, end_offset: 7.days, period: 'weekly'
month = Scheduler::ShiftTime.create! region: arcba, name: 'Monthly', start_offset: 0, end_offset: 31, period: 'monthly'

shift_category = Scheduler::ShiftCategory.create!

[day, night].each do |group|
  [sf, al, sm, so, mr, cc].each do |shift_territory|
    team_lead_shift = Scheduler::Shift.create!(shift_territory: shift_territory, shift_category: shift_category, name: 'Team Lead', abbrev: 'TL', positions: [tl], ordinal: 1, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 1)
    backup_lead_shift = Scheduler::Shift.create!(shift_territory: shift_territory, shift_category: shift_category, name: 'Backup Lead', abbrev: 'BTL', positions: [tl], ordinal: 2, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 2)

    if shift_territory == sf
      dispatch_shift = Scheduler::Shift.create!(shift_territory: shift_territory, shift_category: shift_category, name: 'Dispatch', abbrev: 'Disp', positions: [disp], ordinal: 5, min_desired_signups: 0, max_signups: 1, spreadsheet_ordinal: 3)
    end

    [team_lead_shift, backup_lead_shift, dispatch_shift].compact.each do |created_shift|
      created_shift.shift_times << group
    end

    Scheduler::DispatchConfig.create!(
      name: shift_territory.name,
      shift_territory_id: shift_territory.id,
      region_id: shift_territory.region_id,
      shift_first_id: team_lead_shift.id,
      shift_second_id: backup_lead_shift.id
    )
  end
end

Scheduler::Shift.create!(shift_territory: sf, shift_category: shift_category, name: 'Mental Health', abbrev: 'DMH', positions: [tl], ordinal: 5, min_desired_signups: 0, max_signups: 1).tap do |shift|
  shift.shift_times << week
end

Scheduler::Shift.create!(shift_territory: sf, shift_category: shift_category, name: 'Health Services', abbrev: 'DHS', positions: [tl], ordinal: 6, min_desired_signups: 0, max_signups: 1).tap do |shift|
  shift.shift_times << month
end

test_username = 'test'
test_password = 'password'
Roster::Person.create!(
  first_name: 'Test',
  last_name: 'User',
  email: 'test@example.com',
  username: test_username,
  password: test_password,
  password_confirmation: test_password,
  region: arcba,
  primary_shift_territory: sf,
  cell_phone_carrier: cell_carrier
).tap do |user|
  user.position_memberships.create!(position: region_config_position)
  user.position_memberships.create!(position: region_dat_admin_position)
  user.position_memberships.create!(position: shift_territory_dat_admin_position)
  user.shift_territories << sf
end

puts 'Seeding finished. Created test user with:'
puts "Username: #{test_username}"
puts "Password: #{test_password}"

#Scheduler::Shift.create! shift_territory: sf, name: 'Team Lead', abbrev: 'TL', positions: [tl], shift_time: night, ordinal: 1, max_signups: 1


#load "lib/vc_importer.rb"; 
#vc = Roster::VCImporter.new; 
#vc.import_data(Roster::Region.first, "/Users/jlaxson/Downloads/LMSync1.xls")
