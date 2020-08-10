admin_csv = ARGV[0]

def persistent_position(person_name, region_slug, position_name)
  region = Roster::Region.find_by_slug(region_slug)
  people = Roster::Person.where("CONCAT(first_name, ' ', last_name) like ?", person_name)

  if people.count > 1
    puts "INFO: Person #{person_name} has multiple entries in db"
    person = people.for_region(region).first
  else
    person = people.first
  end

  if person.nil?
    puts "ERROR: Person #{person_name} wasn't in database!"
    return
  end
  position = Roster::Position.where(name: position_name, region: region).first
  if position.nil?
    puts "ERROR: Postition #{position_name} wasn't in database for region #{region_slug}!"
    exit
  end

  if person.positions.include? position
    puts "INFO: Position #{position_name} already associated with #{person_name}"
    return
  end

  Roster::PositionMembership.create(
    person: person,
    position: position,
    persistent: true
  )
end

def get_unique_incident_number(incident, region, n=0)
  working_number = (n == 0) ? incident.incident_number : (incident.incident_number + "-" + n.to_s)
  potential_conflict = Incidents::Incident.for_region(region)[working_number]

  if potential_conflict.present?
    return get_unique_incident_number(incident, region, n + 1)
  else
    return working_number
  end
end

region_config = Roster::Position.where(name: "Region Config", region: Roster::Region.find_by_slug("cni")).first
if region_config.nil?
  region_config = Roster::Position.create(name: "Region Config", abbrev: "Region Config", region: Roster::Region.find_by_slug("cni"))
end
Roster::CapabilityMembership.create(position: region_config, capability: Roster::Capability.where(name: "Region Config").first)

admin_data = CSV.parse(File.read(admin_csv), headers: true)
admin_data.each { |row|
  persistent_position(row["Person Name"], row["Region Slug"], row["Position Name"])
}

Roster::Region.find_by_slug('cni').update_attribute(:vc_hierarchy_name, 'Illinois Region')
Roster::Region.find_by_slug('gold_country').update_attribute(:vc_hierarchy_name, 'California Gold Country Region')
Roster::Region.find_by_slug('cascades').update_attribute(:vc_hierarchy_name, 'Cascades Region')
Roster::Region.find_by_slug('gny').update_attribute(:vc_hierarchy_name, 'Greater New York Region')
Roster::Region.find_by_slug('idaho_montana').update_attribute(:vc_hierarchy_name, 'Idaho and Montana Region')
Roster::Region.find_by_slug('kansas').update_attribute(:vc_hierarchy_name, 'Kansas and Oklahoma Region')
Roster::Region.find_by_slug('southern_minnesota').update_attribute(:vc_hierarchy_name, 'Minnesota and Dakotas Region')
Roster::Region.find_by_slug('nebraska').update_attribute(:vc_hierarchy_name, 'Nebraska and Iowa Region')
Roster::Region.find_by_slug('newjersey').update_attribute(:vc_hierarchy_name, 'New Jersey Region')
Roster::Region.find_by_slug('gsr').update_attribute(:vc_hierarchy_name, 'Northern California Coastal Region')

# The non region we assign old incidents to
deployment_region = Roster::Region.find(0)

incidents = Incidents::Incident.where("date > ?", Date.parse("01-01-2020"))
territories = Incidents::ResponseTerritory.all
n = 0;
print "Realigning #{incidents.count} incidents"
incidents.each do |i|
  if n % 1000 == 0
    print "."
    $stdout.flush
  end
  Incidents::ResponseTerritoryMatcher.new(i, territories).perform
  if i.response_territory.nil?
    i.incident_number = get_unique_incident_number(i, deployment_region)
    i.region = deployment_region
  elsif i.region != i.response_territory.region
    i.incident_number = get_unique_incident_number(i, i.response_territory.region)
    i.region = i.response_territory.region
  end

  i.save!(:validate => false)
  n += 1
end
puts "Done"
