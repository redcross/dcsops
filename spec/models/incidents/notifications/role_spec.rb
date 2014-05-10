require 'spec_helper'

describe Incidents::Notifications::Role do
  it "retrieves its shift members" do
    shift = FactoryGirl.create :shift_with_positions
    person = FactoryGirl.create :person, chapter: shift.shift_group.chapter, counties: [shift.county], positions: shift.positions
    shift.shift_group.update_attributes start_offset: 0, end_offset: 86400
    Scheduler::ShiftAssignment.create! shift: shift, person: person, date: person.chapter.time_zone.today
    role = FactoryGirl.create :notification_role, shifts: [shift], chapter: person.chapter

    role.shift_members.should =~ [person]
  end

  it "retrieves its position members" do
    person = FactoryGirl.create :person
    role = FactoryGirl.create :notification_role, positions: [person.positions.first], chapter: person.chapter

    role.position_members.should =~ [person]
  end
end
