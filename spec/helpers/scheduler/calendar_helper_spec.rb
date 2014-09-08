require 'spec_helper'

describe Scheduler::CalendarHelper, :type => :helper do
  describe "#render_shift_assignment_info" do
    let(:chapter) { FactoryGirl.build_stubbed :chapter }
    let(:person) { double(:person, id: SecureRandom.random_number(100000), first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, first_initial: Faker::Name.first_name[0], full_name: Faker::Name.name) }
    let(:shift) { double(:shift, id: SecureRandom.random_number(100000), name: "Some Shift #{Faker::Name.first_name}", can_be_taken_by?: true, can_sign_up_on_day: true, can_remove_on_day: true, exclusive: true) }
    let(:shift_group) { double(:shift_group, id: SecureRandom.random_number(100000)) }
    let(:date) { Date.current }
    let(:assignment) { double(:shift_assignment, id: SecureRandom.random_number(100000), shift: shift, person: person, shift_group: shift_group) }

    before(:each) { 
      allow(helper).to receive(:show_county_name?).and_return(false)
      allow(helper).to receive(:current_chapter).and_return(chapter)
    }

    it "should render a checkbox when person can sign up" do
      out = helper.render_shift_assignment_info(true, person, shift, shift_group, [], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).to match("checkbox")
      expect(out).to match("daily")
    end
    it "should not render a checkbox when person can't sign up" do
      allow(shift).to receive(:can_be_taken_by?).and_return(false)
      out = helper.render_shift_assignment_info(true, person, shift, shift_group, [], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should not render a checkbox when the shift is closed or full" do
      allow(shift).to receive(:can_sign_up_on_day).and_return(false)
      out = helper.render_shift_assignment_info(true, person, shift, shift_group, [], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should not render a checkbox if editable is false" do
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should not render a checkbox if person is signed up for another shift" do
      allow(assignment).to receive(:shift).and_return(double(:other_shift, exclusive: false))
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [assignment], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should render a checkbox if person is signed up for another non-exclusive shift" do
      allow(assignment).to receive(:shift).and_return(double(:other_shift, exclusive: false))
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [assignment], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should render a checkbox if person is signed up for another shift and this one is non-exclusive" do
      allow(assignment).to receive(:shift).and_return(double(:other_shift, exclusive: true))
      allow(shift).to receive(:exclusive).and_return(false)
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [assignment], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should render a checkbox when person can un-sign up" do
      out = helper.render_shift_assignment_info(true, person, shift, shift_group, [assignment], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).to match("checkbox")
      expect(out).to match(assignment.id.to_s)
    end

    it "should not render a checkbox when person can't un-sign up" do
      allow(shift).to receive(:can_remove_on_day).and_return(false)
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [assignment], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).not_to match("checkbox")
    end

    it "should render OPEN when the shift is empty" do
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [], date, [], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).to match("OPEN")
    end

    it "should render a name when the shift has one person" do
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [], date, [assignment], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).to match("#{person.first_initial} #{person.last_name}")
    end
    it "should render a count when the shift has more than one person" do
      out = helper.render_shift_assignment_info(false, person, shift, shift_group, [], date, [assignment, assignment], 'daily')
      expect(out).to match(shift.name + ":")
      expect(out).to match("2 registered")
      expect(out).to match("#{person.full_name}, #{person.full_name}")
    end

  end
end