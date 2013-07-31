require 'spec_helper'

describe Scheduler::ShiftGroup do
  before(:each) do
    @chapter = FactoryGirl.create(:chapter)
  end
  after(:each) do
    Delorean.back_to_1985
  end

  describe "#current_groups" do
    it "should return current daily groups" do
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 6.hours, end_offset: 12.hours)
      @shift2 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 12.hours, end_offset: 28.hours)

      Delorean.time_travel_to @chapter.time_zone.now.change hour: 6

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      arr.first.start_date.should == @chapter.time_zone.today

      Delorean.time_travel_to@chapter.time_zone.now.change hour: 12

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift2]
      arr.first.start_date.should be_a(Date)
      arr.first.start_date.should == @chapter.time_zone.today

      Delorean.time_travel_to@chapter.time_zone.now.change hour: 5

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ []

      Delorean.time_travel_to @chapter.time_zone.now.change hour: 3

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift2]
      arr.first.start_date.should == @chapter.time_zone.today.yesterday

    end
    it "should return more current daily groups" do
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 0.hours, end_offset: 24.hours)

      Delorean.time_travel_to '2013-06-29 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      arr.first.start_date.should == Date.civil(2013,6,29)
    end

    it "should return current weekly groups" do
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: 1.day, end_offset: 3.days)
      @shift2 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: 3.days, end_offset: 5.days)
      @shift3 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: 6.days, end_offset: 8.days)

      Delorean.time_travel_to 'tuesday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      arr.first.start_date.should be_a(Date)
      arr.first.start_date.should eq Date.current.at_beginning_of_week

      Delorean.time_travel_to 'thursday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift2]
      arr.first.start_date.should eq Date.current.at_beginning_of_week

      Delorean.time_travel_to 'friday 8am'
      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift2]
      arr.first.start_date.should eq Date.current.at_beginning_of_week

      Delorean.time_travel_to 'saturday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ []

      Delorean.time_travel_to 'monday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift3]
      arr.first.start_date.should eq Date.current.at_beginning_of_week.last_week
    end

    it "should return current weekly groups with negative start offset" do
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: -1.day, end_offset: 3.days)

      #Delorean.time_travel_to 'monday 8am'
#
      #(arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      #arr.first.start_date.should eq Date.current.at_beginning_of_week

      Delorean.time_travel_to 'sunday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      arr.first.start_date.should eq @chapter.time_zone.today.at_beginning_of_week.next_week

      Delorean.time_travel_to 'friday 8am'

      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ []
    end

    it "should return current monthly groups" do
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'monthly', start_offset: 0, end_offset: 32)
      (arr = Scheduler::ShiftGroup.current_groups_for_chapter(@chapter)).should =~ [@shift1]
      arr.first.start_date.should be_a(Date)
      arr.first.start_date.should eq @chapter.time_zone.today.at_beginning_of_month
    end

  end

  describe "#next_group" do
    it "should return the next group if daily" do 
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 6.hours, end_offset: 12.hours)
      @shift2 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 12.hours, end_offset: 28.hours)

      Delorean.time_travel_to @chapter.time_zone.now.change hour: 6
      @shift1.start_date = Date.current
      group = @shift1.next_group
      group.should eq @shift2
      group.start_date.should eq @shift1.start_date

      @shift2.start_date = Date.current
      group = @shift2.next_group
      group.should eq @shift1
      group.start_date.should eq @shift2.start_date.tomorrow
    end

    it "should return the next group if weekly" do 
      @shift1 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: 1.day, end_offset: 3.days)
      @shift2 = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'weekly', start_offset: 3.days, end_offset: 7.days)

      Delorean.time_travel_to "tuesday"
      @shift1.start_date = Date.current.at_beginning_of_week
      group = @shift1.next_group
      group.should eq @shift2
      group.start_date.should eq @shift1.start_date

      @shift2.start_date = Date.current.at_beginning_of_week
      group = @shift2.next_group
      group.should eq @shift1
      group.start_date.should eq @shift2.start_date.advance(weeks: 1)
    end

  end
end