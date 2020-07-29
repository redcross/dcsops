def persistent_position(person_name, region_slug, position_name)
  region = Roster::Region.find_by_slug(region_slug)
  person = Roster::Person.for_region(region).where("CONCAT(first_name, ' ', last_name) like ?", person_name).first

  if person.nil?
    "ERROR: Person #{person_name} wasn't in database!"
  end
  position = Roster::Position.where(name: position_name, region: region).first
  if person.nil?
    "ERROR: Postition #{position_name} wasn't in database!"
  end

  Roster::PositionMembership.create(
    person: person,
    position: position,
    persistent: true
  )
end

region_config = Roster::Position.create(name: "Region Config", abbrev: "Region Config", region: Roster::Region.find_by_slug("cni"))
Roster::CapabilityMembership.create(position: region_config, capability: Roster::Capability.where(name: "Region Config").first)

csv.each { |row|
  persistent_position(row["Person Name"], row["Region Slug"], row["Region Config"])
}
