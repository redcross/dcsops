class Roster::Ability
  include CanCan::Ability

  def initialize(person)

    if person
      can :index, Roster::Person, chapter_id: person.chapter_id
      can [:read, :update], Roster::Person, id: person.id
    end

    if person.has_role 'chapter_dat_admin'
      can [:read, :update], Roster::Person, chapter_id: person.chapter_id
    end

    admin_county_ids = person.scope_for_role('county_dat_admin')
    if admin_county_ids.present? # is dat county admin
      can [:read, :update], Roster::Person, county_memberships: {county_id: admin_county_ids}
    end

  end
end
