require 'spec_helper'

describe Scheduler::CalendarController, :type => :controller do
  include LoggedIn
  render_views

  let( :date) { Date.civil(2013,8,8) }
  let( :weekly_date) { date.at_beginning_of_week }
  let( :monthly_date) { date.at_beginning_of_month }

  context "all shifts" do

    before(:each) do
      @ch = @person.region

      @dg = FactoryGirl.create :shift_time, region: @ch, period: 'daily'
      @wg = FactoryGirl.create :shift_time, region: @ch, period: 'weekly', start_offset: 0, end_offset: 7.days
      @mg = FactoryGirl.create :shift_time, region: @ch, period: 'monthly', start_offset: 0, end_offset: 31

      @ds = FactoryGirl.create :shift, shift_times: [@dg], shift_territory: @person.shift_territories.first, positions: @person.positions, spreadsheet_ordinal: 1
      @ws = FactoryGirl.create :shift, shift_times: [@wg], shift_territory: @person.shift_territories.first, positions: @person.positions
      @ms = FactoryGirl.create :shift, shift_times: [@mg], shift_territory: @person.shift_territories.first, positions: @person.positions

      FactoryGirl.create :shift_assignment, shift: @ds, shift_time: @dg, person: @person, date: date
      FactoryGirl.create :shift_assignment, shift: @ws, shift_time: @wg, person: @person, date: weekly_date
      FactoryGirl.create :shift_assignment, shift: @ms, shift_time: @mg, person: @person, date: monthly_date
    end

    it "should render the whole calendar" do
      get :show, params: { month: 'august', year: '2013' }
      expect(response).to be_successful
      expect(response.body).to match(@ds.name)
      expect(response.body).to match(@ws.name)
      expect(response.body).to match(@ms.name)
    end


    it "should render the month" do
      get :month, xhr: true, params: { month: "2013-08" }
      expect(response).to be_successful
      expect(response.body).to match(@ds.name)
      expect(response.body).to match(@ws.name)
      expect(response.body).to match(@ms.name)
    end

    it "should render open shifts" do
      get :show, params: { month: 'august', year: '2013', display: 'open_shifts' }
      expect(response).to be_successful
      expect(response.body).to match(@ds.name)
      expect(response.body).to match(@ws.name)
      expect(response.body).to match(@ms.name)
    end

    it "should render the spreadsheet" do
      get :show, params: { month: 'august', year: '2013', display: 'spreadsheet' }
      expect(response).to be_successful
      expect(response.body).to match(@ds.name)
    end

    args = {
      "default" => {},
      "showing my shifts" => {show_shifts: :mine},
      "showing my with blank person" => {show_shifts: :mine, person_id: ""},
      "showing shift territory shifts" => {show_shifts: :shift_territory},
      "showing shift territory with no person" => {show_shifts: :shift_territory, person_id: ""},
      "showing shift territory shifts with blank shift_territories" => {show_shifts: :shift_territory, :shift_territories => []},
      "showing shift territory shifts with lots of shift_territories" => {show_shifts: :shift_territory, :shift_territories => Roster::ShiftTerritory.all.map(&:id)},
      "showing all shifts" => {show_shifts: :all},
      "showing all shifts with no person" => {show_shifts: :all, person_id: ""},
    }

    args.each do |name, extra_params|
      context name do

        it "should render the whole calendar" do
          get :show, params: extra_params.merge({month: 'august', year: '2013'})
          expect(response).to be_successful
        end


        it "should render the month" do
          get :month, xhr: true, params: extra_params.merge({month: "2013-08"})
          expect(response).to be_successful
        end

        it "should render open shifts" do
          get :show, xhr: true, params: extra_params.merge({month: 'august', year: '2013', display: 'open_shifts'})
          expect(response).to be_successful
        end

        it "should render the spreadsheet" do
          get :show, params: extra_params.merge({month: 'august', year: '2013', display: 'spreadsheet'})
          expect(response).to be_successful
        end
      end
    end

    context "user without shift territories" do
      before(:each) do
        @person.shift_territories = [];
        @person.save
      end

      it "should render the whole calendar" do
        get :show, params: { month: 'august', year: '2013' }
        expect(response).to be_successful
      end

      it "should render the month" do
        get :month, xhr: true, params: { month: "2013-08" }
        expect(response).to be_successful
      end

      it "should render open shifts" do
        get :show, xhr: true, params: { month: 'august', year: '2013', display: 'open_shifts' }
        expect(response).to be_successful
      end

      it "should render the spreadsheet" do
        get :show, params: { month: 'august', year: '2013', display: 'spreadsheet' }
        expect(response).to be_successful
      end
    end

    context "specifying empty shift territories" do
      it "should render the whole calendar" do
        get :show, params: { month: 'august', year: '2013', shift_territories: [], show_shifts: 'shift_territory' }
        expect(response).to be_successful
      end

      it "should render the spreadsheet" do
        get :show, params: { month: 'august', year: '2013', display: 'spreadsheet', shift_territories: [], show_shifts: 'shift_territory' }
        expect(response).to be_successful
      end
    end
  end

  date = Date.current + 365
  weekly_date = date.at_beginning_of_week
  monthly_date = date.at_beginning_of_month
  
  periods = {
      'day' => {
        date: date,
        prev_date: date.yesterday,
        next_date: date.tomorrow,
        later_date: date.tomorrow.tomorrow,
        shift_period: 'daily',
        shift_start_offset: 10.hours,
        shift_end_offset: 14.hours
      },
      'week' => {
        date: weekly_date,
        prev_date: weekly_date.last_week,
        next_date: weekly_date.next_week,
        later_date: weekly_date.next_week.next_week,
        shift_period: 'weekly',
        shift_start_offset: -1.day,
        shift_end_offset: 6.days
      },
      'monthly' => {
        date: monthly_date,
        prev_date: monthly_date.last_month,
        next_date: monthly_date.next_month,
        later_date: monthly_date.next_month.next_month,
        shift_period: 'monthly',
        shift_start_offset: 0,
        shift_end_offset: 131
      }
    }

  periods.each do |partial_name, values|
    describe "#{partial_name} partial" do
      before :each do
        @ch = @person.region
        @group = FactoryGirl.create :shift_time, region: @ch, period: values[:shift_period], start_offset: values[:shift_start_offset], end_offset: values[:shift_end_offset]
        @shift = FactoryGirl.create :shift, shift_times: [@group], shift_territory: @person.shift_territories.first, positions: @person.positions
        @assignment = FactoryGirl.create :shift_assignment, shift: @shift, shift_time: @group, person: @person, date: values[:date]
      end

      it "should render" do
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match(@shift.name)
      end

      it "should be possible to sign up" do
        get :day, xhr: true, params: { date: values[:next_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match("checkbox")
      end

      it "should be possible to un-sign up" do
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match("checkbox")
      end

      it "should not show shift if the shift has ended" do
        @shift.update_attribute(:shift_ends, values[:prev_date])
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match(@shift.name)
      end

      it "should not show shift if the shift hasn't started" do
        @shift.update_attribute(:shift_begins, values[:next_date])
        get :day, xhr: true, params: { date: values[:prev_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match(@shift.name)
      end

      it "should not be possible to un-sign up if the shift is frozen" do
        @shift.update_attribute(:signups_frozen_before, values[:later_date])
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match("checkbox")
      end

      it "should be possible to un-sign up after the shift is frozen" do
        @shift.update_attribute(:signups_frozen_before, values[:next_date])
        get :day, xhr: true, params: { date: values[:later_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match("checkbox")
      end

      it "should not be possible to sign up after the shift available day" do
        @shift.update_attribute(:signups_available_before, values[:next_date])
        get :day, xhr: true, params: { date: values[:later_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match("checkbox")
      end

      it "should be possible to sign up before the shift available day" do
        @shift.update_attribute(:signups_available_before, values[:later_date])
        get :day, xhr: true, params: { date: values[:next_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match("checkbox")
      end

      it "should be possible to sign up in less than the advance days" do
        days_to = (values[:next_date] - @ch.time_zone.today)

        @shift.update_attribute(:max_advance_signup, days_to + 5)
        get :day, xhr: true, params: { date: values[:next_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match("checkbox")
      end

      it "should not be possible to sign up in more than the advance days" do
        days_to = (values[:next_date] - @ch.time_zone.today)
        @shift.update_attribute(:max_advance_signup, days_to - 5)
        get :day, xhr: true, params: { date: values[:next_date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match("checkbox")
      end

      it "should highlight if the shift has less than desired signups" do
        FactoryGirl.create :shift_assignment, shift: @shift, shift_time: @group, person: @person, date: values[:prev_date]
        @shift.update_attribute :min_desired_signups, 2
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).to match(/class=['"]open/)
      end

      it "should not highlight if the shift has the desired signups" do
        FactoryGirl.create :shift_assignment, shift: @shift, shift_time: @group, person: @person, date: values[:prev_date]
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response).to be_successful
        expect(response.body).not_to match(/class=['"]open/)
      end

      if partial_name != 'week'
        it "should render the shift time name" do
          get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
          expect(response.body).to match(@group.name)
        end
      end

      it "should not render an empty group's name" do
        @empty_group = FactoryGirl.create :shift_time, name: "EmptyGroup", region: @ch, period: values[:shift_period], start_offset: values[:shift_start_offset], end_offset: values[:shift_end_offset]
        @old_shift = FactoryGirl.create :shift, shift_times: [@empty_group], shift_territory: @person.shift_territories.first, positions: @person.positions, shift_ends: values[:date]-5
        get :day, xhr: true, params: { date: values[:date].to_s, period: partial_name }
        expect(response.body).not_to match(@empty_group.name)
      end
    end

  end

end