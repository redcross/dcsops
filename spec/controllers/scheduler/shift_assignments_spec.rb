require 'spec_helper'

describe Scheduler::ShiftAssignmentsController do
  before(:each) do
    @person = FactoryGirl.create :person
    @chapter = @person.chapter
    @person2 = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties, positions: @person.positions
    @shift = FactoryGirl.create :shift, county: @person.counties.first, positions: @person.positions

    @assignments = (1..5).map{|i| Scheduler::ShiftAssignment.create! person:@person, date:Date.today+i, shift:@shift}

    @settings = Scheduler::NotificationSetting.create id: @person.id
  end

  it "when not logged in, should be unauthorized" do
    get :index, format: :ics

    response.code.should eq "401"
  end

  it "with invalid api token, should be unauthorized" do
    get :index, format: :ics, api_token: "test123"

    response.code.should eq "401"
  end


  context "#index.ics" do
    render_views

    it "should allow exporting my shifts to calendar" do
      get :index, format: :ics, api_token: @settings.calendar_api_token

      response.code.should eq "200"
      response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
    end

    it "should only include my shifts on the calendar" do
      3.times { FactoryGirl.create :shift_assignment }

      get :index, format: :ics, api_token: @settings.calendar_api_token

      response.code.should eq "200"
      response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
    end

    pending "should include daily, weekly, monthly shifts"
    pending "daily shifts should have a date and time"
    pending "weekly/monthly shifts should have only a day"

    context "?show_shifts=all" do
      it "should access denied if a regular user" do
        3.times { FactoryGirl.create :shift_assignment }
        expect {
          get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'
        }.to raise_error(CanCan::AccessDenied)
      end

      it 'should show all shifts I am a county admin for' do
        (0..2).map { |i| 
          pers = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties
          shift = FactoryGirl.create :shift, shift_group: @shift.shift_group, county: pers.counties.first, positions: pers.positions
          FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+6+i), shift: shift
        }

        grant_role! 'county_dat_admin', @person.county_ids, @person

        get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'

        response.code.should eq "200"
        response.body.scan(/BEGIN:VEVENT/).count.should eq(8)
      end

      it "should merge other shifts into the same event" do
        county = @person.counties.first
        (1..3).map { |i| 
          pers = FactoryGirl.create :person, chapter: @chapter, counties: @person.counties
          shift = FactoryGirl.create :shift, shift_group: @shift.shift_group, county: pers.counties.first, positions: pers.positions
          FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+i), shift: shift
        }

        grant_role! 'county_dat_admin', @person.county_ids, @person

        get :index, format: :ics, api_token: @settings.calendar_api_token, show_shifts: 'all'

        response.code.should eq "200"
        response.body.scan(/BEGIN:VEVENT/).count.should eq(5)
      end
    end
  end
end