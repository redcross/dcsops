class Roster::Ability
  include CanCan::Ability

  def initialize(person)

    if person
      can :index, Roster::Person, region_id: person.region_id
      can [:index, :read, :update], Roster::Person, id: person.id

      can :search_people, Roster::Region, id: person.region_id
      can :search_people, Roster::Region, Roster::Region.with_incidents_delegate_region_value(person.region_id) do |region|
        region.incidents_delegate_region == person.region_id
      end
    end

    if person.has_role 'region_dat_admin'
      can [:read, :update], Roster::Person, region_id: person.region_id
    end

    admin_county_ids = person.scope_for_role('county_dat_admin')
    if admin_county_ids.present? # is dat county admin
      can [:read, :update], Roster::Person, county_memberships: {county_id: admin_county_ids}
    end

  end
end
