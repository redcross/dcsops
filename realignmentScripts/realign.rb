require 'csv'

csv_dir = ARGV[0]
csv_basename = ARGV[1]
region_slug = ARGV[2]
people_r_slugs = ARGV[3..-1]

#ActiveRecord::Base.logger = Logger.new(STDOUT)
r = Roster::Region.find_by_slug(region_slug)
people_rs = people_r_slugs.map {|slug| Roster::Region.find_by_slug(slug) }
shifts = Scheduler::Shift.for_region(r)

puts "VC Positions: " + Roster::VcPosition.where(region: r).length.to_s
puts "VC Position Configurations: " + Roster::VcPositionConfiguration.for_region(r).length.to_s
puts "Positions: " + Roster::Position.where(region: r).length.to_s
puts "Dispatch Configs: " + Scheduler::DispatchConfig.where(region: r).length.to_s
puts "Response Territories: " + Incidents::ResponseTerritory.where(region: r).length.to_s
puts "Shift Assignments: " + Scheduler::ShiftAssignment.for_shifts(shifts).length.to_s
puts "Shifts: " + Scheduler::Shift.for_region(r).length.to_s
puts "Shift Territories: " + Roster::ShiftTerritory.where(region: r).length.to_s
puts "Shift Times: " + Scheduler::ShiftTime.where(region: r).length.to_s

Roster::VcPositionConfiguration.for_region(r).delete_all
Roster::VcPosition.where(region: r).delete_all
Roster::Position.where(region: r).delete_all
Roster::PositionMembership.for_region(r).delete_all
Roster::ShiftTerritoryMembership.for_region(r).delete_all
Scheduler::DispatchConfig.where(region: r).delete_all
Incidents::ResponseTerritory.where(region: r).delete_all
Scheduler::ShiftAssignment.for_shifts(shifts).delete_all
Scheduler::Shift.for_region(r).delete_all
Roster::ShiftTerritory.where(region: r).delete_all
Scheduler::ShiftTime.where(region: r).delete_all

vc_position_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Volunteer Connection Positions.csv"), headers: true)
vc_position_data.each do |p_d|
  if p_d["Volunteer Connection Position"].nil? || p_d["Volunteer Connection Position"].strip.empty?
    next
  end
  Roster::VcPosition.create(name: p_d["Volunteer Connection Position"].strip, region: r)
end

position_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - DCSOps Positions.csv"), headers: true)
position_data.each do |p_d|
  if p_d["Position"].nil?
    next
  end
  p = Roster::Position.create(
    name: p_d["Position"],
    abbrev: p_d["Abbreviation"],
    region: r)

  if not p_d["Capabilities (Roles)"].nil?
    capability_names = p_d["Capabilities (Roles)"].split("\n")
    capability_names.each do |n|
      c = Roster::Capability.where(name: n)
      if c.nil?
        puts "ERROR: Oh no, #{n} doesn't seem to be in the database!"
      else
        Roster::CapabilityMembership.create(position: p, capability: c[0])
      end
    end
  end
end

response_territory_data = CSV.read("#{csv_dir}/#{csv_basename} - Response Territories.csv")

(1..(response_territory_data[0].size)).each do |idx|
  r_t = response_territory_data[0][idx]
  counties = response_territory_data[1][idx].split("\n") unless response_territory_data[1][idx].nil?
  cities = response_territory_data[2][idx].split("\n") unless response_territory_data[2][idx].nil?
  zips = response_territory_data[3][idx].split("\n") unless response_territory_data[3][idx].nil?

  Incidents::ResponseTerritory.create(
    name: r_t,
    region: r,
    counties: counties,
    cities: cities,
    zip_codes: zips,
    enabled: true
  )
end

shift_territory_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Shift Territories.csv"), headers: true)
shift_territory_data.each do |s_t|
  if s_t["Shift Territory"].nil?
    next
  end
  Roster::ShiftTerritory.create(
    region: r,
    name: s_t["Shift Territory"],
    abbrev: s_t["Abbreviation"]
  )
end

shift_time_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Shift Times.csv"), headers: true)
shift_time_data.each do |s_ts|
  if s_ts["Shift Times"].nil?
    next
  end
  s_ts["Shift Times"].split("\n").each{ |s_t|
    s = Scheduler::ShiftTime.create(
      region: r,
      name: s_t,
      start_offset: 0,
      end_offset: 1234,
      period: :daily
    )
  }
end

shift_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Shifts.csv"), headers: true)
shift_data.each do |s|
  if s["Shift Territory"].nil?
    next
  end
  shift_territory = Roster::ShiftTerritory.where(region: r, name: s["Shift Territory"]).first
  if shift_territory.nil?
    puts "ERROR: Can't find shift territory #{s['Shift Territory']}"
    exit
  end

  position = Roster::Position.where(region: r, name: s["DCSOps Position"]).first
  if position.nil?
    puts "ERROR: Can't find position #{s['DCSOps Position']}"
    exit
  end

  shift_times = s["Shift Times"].split("\n").map{ |shift_time_name|
    shift_time = Scheduler::ShiftTime.where(region: r, name: shift_time_name).first
    if shift_time.nil?
      puts "ERROR: Can't find shift time #{shift_time_name}"
      exit
    end
    shift_time
  }

  shift_category = Scheduler::ShiftCategory.where(region: r, name: s["Shift Category"]).first
  if shift_category.nil?
    puts "ERROR: Can't find shift category #{s['Shift Category']}"
    exit
  end

  s["Volunteer Connection Position(s)"].split("\n").each do |vc_pos_name|
    vc_position = Roster::VcPosition.where(region: r, name: vc_pos_name.strip).first

    if vc_position.nil?
      puts "ERROR: Can't find vc position #{vc_pos_name}"
      exit
    end

    Roster::VcPositionConfiguration.create(
      shift_territory: shift_territory,
      vc_position: vc_position,
      position: position
    )
  end

  name = s["Shift Name"]
  abbrev = s["Abbreviation"]
  max_signups = s["Sign-ups"].to_i
  ordinal = s["Ordinal"].to_i
  exclusive = (s["Exclusive"] == "Yes")
  show_in_dispatch_console = (s["Show in Dispatch Console"] == "Yes")

  s = Scheduler::Shift.create(
    shift_territory: shift_territory,
    positions: [position],
    shift_times: shift_times,
    shift_category: shift_category,
    name: name,
    abbrev: abbrev,
    min_desired_signups: 1,
    max_signups: max_signups,
    ordinal: ordinal,
    exclusive: exclusive,
    show_in_dispatch_console: show_in_dispatch_console
  )

  s.save!
end

notification_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Notifications.csv"), headers: true)
notification_data.each do |n|
  if n["Members"].nil?
    next
  end

  position = Roster::Position.where(region: r, name: n["Members"]).first
  if position.nil?
    puts "ERROR: Can't find position #{n['Members']}"
    exit
  end

  vc_position = Roster::VcPosition.where(region: r, name: n["Volunteer Connection Position"]).first
  if vc_position.nil?
    puts "ERROR: Can't find vc position #{n["Volunteer Connection Position"]}"
    exit
  end

  Roster::VcPositionConfiguration.create(
    vc_position: vc_position,
    position: position
  )
end

dispatch_config_data = CSV.parse(File.read("#{csv_dir}/#{csv_basename} - Dispatch Configuration.csv"), headers: true)
dispatch_config_data.each do |s|
  find_shift = lambda do |shift_name, shift_territory|
    if shift_name.nil?
      return
    end
    shift = Scheduler::Shift.for_region(r).where(name: shift_name).first
    if shift.nil?
      puts "ERROR: Can't find shift #{shift_name}."
      exit
    end
    shift
  end
  find_person = lambda do |person_name|
    if person_name.nil?
      return
    end
    person = Roster::Person.where(region: people_rs).where("CONCAT(first_name, ' ', last_name) like ?", person_name).first
    if person.nil?
      puts "ERROR: Can't find person #{person_name}"
      exit
    end
    person
  end
  shift_territory_name = s["Shift Territory"]
  if shift_territory_name.nil?
    next
  end
  shift_territory = Roster::ShiftTerritory.where(region: r, name: s["Shift Territory"]).first
  if shift_territory.nil?
    puts "ERROR: Can't find shift territory #{s['Shift Territory']}"
    exit
  end
  shift_first = find_shift.call(s["Shift first"], shift_territory)
  shift_second = find_shift.call(s["Shift second"], shift_territory)
  shift_third = find_shift.call(s["Shift third"], shift_territory)
  shift_fourth = find_shift.call(s["Shift fourth"], shift_territory)
  backup_first = find_person.call(s["Backup first"])
  backup_second = find_person.call(s["Backup second"])
  backup_third = find_person.call(s["Backup third"])
  backup_fourth = find_person.call(s["Backup fourth"])

  Scheduler::DispatchConfig.create(
    region: r,
    name: shift_territory_name,
    shift_territory: shift_territory,
    shift_first: shift_first,
    shift_second: shift_second,
    shift_third: shift_third,
    shift_fourth: shift_fourth,
    backup_first: backup_first,
    backup_second: backup_second,
    backup_third: backup_third,
    backup_fourth: backup_fourth
  ).save!
end

puts "Unused VC positions:"
Roster::VcPosition.where(region: r).joins('left join roster_vc_position_configurations on "roster_vc_position_configurations"."vc_position_id" = "roster_vc_positions"."id"').where('"roster_vc_position_configurations"."id" is null').uniq.map(&:name).map{|s| puts "  " + s}
