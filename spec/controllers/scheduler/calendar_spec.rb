require 'spec_helper'

describe Scheduler::CalendarController do
  include LoggedIn
  render_views

  let( :date) { Date.civil(2013,8,8) }
  let( :weekly_date) { date.at_beginning_of_week }
  let( :monthly_date) { date.at_beginning_of_month }

  context "all shifts" do

    before(:each) do
      @ch = @person.chapter

      @dg = FactoryGirl.create :shift_group, chapter: @ch, period: 'daily'
      @wg = FactoryGirl.create :shift_group, chapter: @ch, period: 'weekly', start_offset: 0, end_offset: 7.days
      @mg = FactoryGirl.create :shift_group, chapter: @ch, period: 'monthly', start_offset: 0, end_offset: 31

      @ds = FactoryGirl.create :shift, shift_groups: [@dg], county: @person.counties.first, positions: @person.positions, spreadsheet_ordinal: 1
      @ws = FactoryGirl.create :shift, shift_groups: [@wg], county: @person.counties.first, positions: @person.positions
      @ms = FactoryGirl.create :shift, shift_groups: [@mg], county: @person.counties.first, positions: @person.positions

      FactoryGirl.create :shift_assignment, shift: @ds, shift_group: @dg, person: @person, date: date
      FactoryGirl.create :shift_assignment, shift: @ws, shift_group: @wg, person: @person, date: weekly_date
      FactoryGirl.create :shift_assignment, shift: @ms, shift_group: @mg, person: @person, date: monthly_date
    end

    it "should render the whole calendar" do
      get :show, month: 'august', year: '2013'
      response.should be_success
      response.body.should match(@ds.name)
      response.body.should match(@ws.name)
      response.body.should match(@ms.name)
    end


    it "should render the month" do
      xhr :get, :month, month: "2013-08"
      response.should be_success
      response.body.should match(@ds.name)
      response.body.should match(@ws.name)
      response.body.should match(@ms.name)
    end

    it "should render open shifts" do
      get :show, month: 'august', year: '2013', display: 'open_shifts'
      response.should be_success
      response.body.should match(@ds.name)
      response.body.should match(@ws.name)
      response.body.should match(@ms.name)
    end

    it "should render the spreadsheet" do
      get :show, month: 'august', year: '2013', display: 'spreadsheet'
      response.should be_success
      response.body.should match(@ds.name)
    end

    args = {
      "default" => {},
      "showing my shifts" => {show_shifts: :mine},
      "showing my with blank person" => {show_shifts: :mine, person_id: ""},
      "showing county shifts" => {show_shifts: :county},
      "showing county with no person" => {show_shifts: :county, person_id: ""},
      "showing county shifts with blank counties" => {show_shifts: :county, :counties => []},
      "showing county shifts with lots of counties" => {show_shifts: :county, :counties => Roster::County.all.map(&:id)},
      "showing all shifts" => {show_shifts: :all},
      "showing all shifts with no person" => {show_shifts: :all, person_id: ""},
    }

    args.each do |name, extra_params|
      context name do

        it "should render the whole calendar" do
          get :show, extra_params.merge({month: 'august', year: '2013'})
          response.should be_success
        end


        it "should render the month" do
          xhr :get, :month, extra_params.merge({month: "2013-08"})
          response.should be_success
        end

        it "should render open shifts" do
          xhr :get, :show, extra_params.merge({month: 'august', year: '2013', display: 'open_shifts'})
          response.should be_success
        end

        it "should render the spreadsheet" do
          get :show, extra_params.merge({month: 'august', year: '2013', display: 'spreadsheet'})
          response.should be_success
        end
      end
    end

    context "user without counties" do
      before(:each) do
        @person.counties = [];
        @person.save
      end

      it "should render the whole calendar" do
        get :show, month: 'august', year: '2013'
        response.should be_success
      end

      it "should render the month" do
        xhr :get, :month, month: "2013-08"
        response.should be_success
      end

      it "should render open shifts" do
        xhr :get, :show, month: 'august', year: '2013', display: 'open_shifts'
        response.should be_success
      end

      it "should render the spreadsheet" do
        get :show, month: 'august', year: '2013', display: 'spreadsheet'
        response.should be_success
      end
    end

    context "specifying empty counties" do
      it "should render the whole calendar" do
        get :show, month: 'august', year: '2013', counties: [], show_shifts: 'county'
        response.should be_success
      end

      it "should render the spreadsheet" do
        get :show, month: 'august', year: '2013', display: 'spreadsheet', counties: [], show_shifts: 'county'
        response.should be_success
      end
    end
  end

  date = Date.civil(2014,8,8)
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
        @ch = @person.chapter
        @group = FactoryGirl.create :shift_group, chapter: @ch, period: values[:shift_period], start_offset: values[:shift_start_offset], end_offset: values[:shift_end_offset]
        @shift = FactoryGirl.create :shift, shift_groups: [@group], county: @person.counties.first, positions: @person.positions
        @assignment = FactoryGirl.create :shift_assignment, shift: @shift, shift_group: @group, person: @person, date: values[:date]
      end

      it "should render" do
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should match(@shift.name)
      end

      it "should be possible to sign up" do
        xhr :get, :day, date: values[:next_date].to_s, period: partial_name
        response.should be_success
        response.body.should match("checkbox")
      end

      it "should be possible to un-sign up" do
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should match("checkbox")
      end

      it "should not show shift if the shift has ended" do
        @shift.update_attribute(:shift_ends, values[:prev_date])
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match(@shift.name)
      end

      it "should not show shift if the shift hasn't started" do
        @shift.update_attribute(:shift_begins, values[:next_date])
        xhr :get, :day, date: values[:prev_date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match(@shift.name)
      end

      it "should not be possible to un-sign up if the shift is frozen" do
        @shift.update_attribute(:signups_frozen_before, values[:later_date])
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match("checkbox")
      end

      it "should be possible to un-sign up after the shift is frozen" do
        @shift.update_attribute(:signups_frozen_before, values[:next_date])
        xhr :get, :day, date: values[:later_date].to_s, period: partial_name
        response.should be_success
        response.body.should match("checkbox")
      end

      it "should not be possible to sign up after the shift available day" do
        @shift.update_attribute(:signups_available_before, values[:next_date])
        xhr :get, :day, date: values[:later_date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match("checkbox")
      end

      it "should be possible to sign up before the shift available day" do
        @shift.update_attribute(:signups_available_before, values[:later_date])
        xhr :get, :day, date: values[:next_date].to_s, period: partial_name
        response.should be_success
        response.body.should match("checkbox")
      end

      it "should be possible to sign up in less than the advance days" do
        days_to = (values[:next_date] - @ch.time_zone.today)

        @shift.update_attribute(:max_advance_signup, days_to + 5)
        xhr :get, :day, date: values[:next_date].to_s, period: partial_name
        response.should be_success
        response.body.should match("checkbox")
      end

      it "should not be possible to sign up in more than the advance days" do
        days_to = (values[:next_date] - @ch.time_zone.today)
        @shift.update_attribute(:max_advance_signup, days_to - 5)
        xhr :get, :day, date: values[:next_date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match("checkbox")
      end

      it "should highlight if the shift has less than desired signups" do
        FactoryGirl.create :shift_assignment, shift: @shift, shift_group: @group, person: @person, date: values[:prev_date]
        @shift.update_attribute :min_desired_signups, 2
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should match(/class=['"]open/)
      end

      it "should not highlight if the shift has the desired signups" do
        FactoryGirl.create :shift_assignment, shift: @shift, shift_group: @group, person: @person, date: values[:prev_date]
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.should be_success
        response.body.should_not match(/class=['"]open/)
      end

      if partial_name != 'week'
        it "should render the shift group name" do
          xhr :get, :day, date: values[:date].to_s, period: partial_name
          response.body.should match(@group.name)
        end
      end

      it "should not render an empty group's name" do
        @empty_group = FactoryGirl.create :shift_group, name: "EmptyGroup", chapter: @ch, period: values[:shift_period], start_offset: values[:shift_start_offset], end_offset: values[:shift_end_offset]
        @old_shift = FactoryGirl.create :shift, shift_groups: [@empty_group], county: @person.counties.first, positions: @person.positions, shift_ends: values[:date]-5
        xhr :get, :day, date: values[:date].to_s, period: partial_name
        response.body.should_not match(@empty_group.name)
      end
    end

  end

end