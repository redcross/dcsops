def persistent_position(person_name, region_slug, position_name)
  region = Roster::Region.find_by_slug(region_slug)
  person = Roster::Person.for_region(region).where("CONCAT(first_name, ' ', last_name) like ?", person_name).first
  position = Roster::Position.where(name: position_name, region: region).first

  Roster::PositionMembership.create(
    person: person,
    position: position,
    persistent: true
  )
end

region_config = Roster::Position.create(name: "Region Config", abbrev: "Region Config", region: Roster::Region.find_by_slug("cni"))
Roster::CapabilityMembership.create(position: region_config, capability: Roster::Capability.where(name: "Region Config").first)

