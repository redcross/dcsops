require 'spec_helper'

describe Scheduler::CalendarHelper do
  describe "#render_shift_assignment_info" do
    let(:person) { double(:person, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, first_initial: Faker::Name.first_name[0], full_name: Faker::Name.name) }
    let(:shift) { double(:shift, id: SecureRandom.random_number(100000), name: "Some Shift #{Faker::Name.first_name}", can_be_taken_by?: true, can_sign_up_on_day: true, can_remove_on_day: true) }
    let(:date) { Date.current }
    let(:assignment) { double(:shift_assignment, id: SecureRandom.random_number(100000), shift: shift, person: person) }

    before(:each) { helper.stub show_county_name?: false}

    it "should render a checkbox when person can sign up" do
      out = helper.render_shift_assignment_info(true, person, shift, nil, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should match("checkbox")
      out.should match("daily")
    end
    it "should not render a checkbox when person can't sign up" do
      shift.stub can_be_taken_by?: false
      out = helper.render_shift_assignment_info(true, person, shift, nil, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should_not match("checkbox")
    end

    it "should not render a checkbox when the shift is closed or full" do
      shift.stub can_sign_up_on_day: false
      out = helper.render_shift_assignment_info(true, person, shift, nil, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should_not match("checkbox")
    end

    it "should not render a checkbox if editable is false" do
      out = helper.render_shift_assignment_info(false, person, shift, nil, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should_not match("checkbox")
    end

    it "should not render a checkboxif person is signed up for another shift" do
      assignment.stub shift: double(:other_shift)
      out = helper.render_shift_assignment_info(false, person, shift, assignment, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should_not match("checkbox")
    end

    it "should render a checkbox when person can un-sign up" do
      out = helper.render_shift_assignment_info(true, person, shift, assignment, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should match("checkbox")
      out.should match(assignment.id.to_s)
    end

    it "should not render a checkbox when person can't un-sign up" do
      shift.stub can_remove_on_day: false
      out = helper.render_shift_assignment_info(false, person, shift, assignment, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should_not match("checkbox")
    end


    it "should render OPEN when the shift is empty" do
      out = helper.render_shift_assignment_info(false, person, shift, nil, date, [], 'daily')
      out.should match(shift.name + ":")
      out.should match("OPEN")
    end

    it "should render a name when the shift has one person" do
      out = helper.render_shift_assignment_info(false, person, shift, nil, date, [assignment], 'daily')
      out.should match(shift.name + ":")
      out.should match("#{person.first_initial} #{person.last_name}")
    end
    it "should render a count when the shift has more than one person" do
      out = helper.render_shift_assignment_info(false, person, shift, nil, date, [assignment, assignment], 'daily')
      out.should match(shift.name + ":")
      out.should match("2 registered")
      out.should match("#{person.full_name}, #{person.full_name}")
    end

  end
end