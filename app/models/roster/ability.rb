class Roster::Ability
  include CanCan::Ability

  def initialize(person)

    if person
      can :index, Roster::Person, chapter_id: person.chapter_id
      can [:index, :read, :update], Roster::Person, id: person.id

      can :search_people, Roster::Chapter, id: person.chapter_id
      can :search_people, Roster::Chapter, Roster::Chapter.with_incidents_delegate_chapter_value(person.chapter_id) do |chapter|
        chapter.incidents_delegate_chapter == person.chapter_id
      end
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
