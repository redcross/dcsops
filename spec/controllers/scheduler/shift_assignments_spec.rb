require 'spec_helper'

describe Scheduler::ShiftAssignmentsController, :type => :controller do
  before(:each) do
    @person = FactoryGirl.create :person
    @region = @person.region
    @person2 = FactoryGirl.create :person, region: @region, shift_territories: @person.shift_territories, positions: @person.positions
    @shift = FactoryGirl.create :shift, shift_territory: @person.shift_territories.first, positions: @person.positions
    @shift_time = @shift.shift_times.first

    @assignments = (1..5).map{|i| Scheduler::ShiftAssignment.create! person:@person, date:Date.today+i, shift:@shift, shift_time:@shift_time}

    @settings = Scheduler::NotificationSetting.create id: @person.id
  end

  it "when not logged in, should be unauthorized" do
    get :index, params: { format: :ics }

    expect(response.code).to eq "401"
  end

  it "with invalid api token, should be unauthorized" do
    get :index, format: :ics, params: { api_token: "test123" }

    expect(response.code).to eq "401"
  end


  context "#index.ics" do
    render_views

    it "should allow exporting my shifts to calendar" do
      get :index, params: { format: :ics, api_token: @settings.calendar_api_token }

      expect(response.code).to eq "200"
      expect(response.body.scan(/BEGIN:VEVENT/).count).to eq(5)
    end

    it "should only include my shifts on the calendar" do
      3.times { FactoryGirl.create :shift_assignment }

      get :index, params: { format: :ics, api_token: @settings.calendar_api_token }

      expect(response.code).to eq "200"
      expect(response.body.scan(/BEGIN:VEVENT/).count).to eq(5)
    end

    skip "should include daily, weekly, monthly shifts"
    skip "daily shifts should have a date and time"
    skip "weekly/monthly shifts should have only a day"

    context "?show_shifts=all" do
      it "should access denied if a regular user" do
        3.times { FactoryGirl.create :shift_assignment }
        get :index, format: :ics, params: { api_token: @settings.calendar_api_token, show_shifts: 'all' }
        expect(response.code).to eq "403"
        expect(flash[:error]).to match("You are not authorized to access that page.")
      end

      it 'should show all shifts I am a shift territory admin for' do
        (0..2).map { |i| 
          pers = FactoryGirl.create :person, region: @region, shift_territories: @person.shift_territories
          shift = FactoryGirl.create :shift, shift_times: [@shift_time], shift_territory: pers.shift_territories.first, positions: pers.positions
          FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+6+i), shift: shift, shift_time: @shift_time
        }

        grant_capability! 'shift_territory_dat_admin', @person.shift_territory_ids, @person

        get :index, format: :ics, params: { api_token: @settings.calendar_api_token, show_shifts: 'all' }

        expect(response.code).to eq "200"
        expect(response.body.scan(/BEGIN:VEVENT/).count).to eq(8)
      end

      it "should merge other shifts into the same event" do
        shift_territory = @person.shift_territories.first
        (1..3).map { |i| 
          pers = FactoryGirl.create :person, region: @region, shift_territories: @person.shift_territories
          shift = FactoryGirl.create :shift, shift_times: [@shift_time], shift_territory: pers.shift_territories.first, positions: pers.positions
          FactoryGirl.create :shift_assignment, person: pers, date: (Date.today+i), shift: shift, shift_time: @shift_time
        }

        grant_capability! 'shift_territory_dat_admin', @person.shift_territory_ids, @person

        get :index, format: :ics, params: { api_token: @settings.calendar_api_token, show_shifts: 'all' }

        expect(response.code).to eq "200"
        expect(response.body.scan(/BEGIN:VEVENT/).count).to eq(5)
      end
    end
  end
end