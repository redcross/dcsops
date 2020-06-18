require 'spec_helper'

describe Incidents::Notifications::Role, :type => :model do
  it "retrieves its shift members" do
    shift = FactoryGirl.create :shift_with_positions
    person = FactoryGirl.create :person, region: shift.shift_territory.region, shift_territories: [shift.shift_territory], positions: shift.positions
    shift.shift_times.first.update_attributes start_offset: 0, end_offset: 86400
    FactoryGirl.create :shift_assignment, shift: shift, person: person, date: person.region.time_zone.today
    role = FactoryGirl.create :notification_role, shifts: [shift], region: person.region

    expect(role.shift_members).to match_array([person])
  end

  it "retrieves its position members" do
    person = FactoryGirl.create :person
    role = FactoryGirl.create :notification_role, positions: [person.positions.first], region: person.region

    expect(role.position_members).to match_array([person])
  end
end
