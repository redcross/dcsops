require 'spec_helper'

describe "scheduler_periodic:send_reminders" do
  include_context "rake"

  its(:prerequisites) { should include('send_invites', 'send_email', 'send_sms', 'send_daily_email', 'send_daily_sms')}
end

describe "" do
  include_context "rake"
  let(:task_name) { self.class.description }

  before(:each) do
    @chapter = FactoryGirl.create :chapter
    @person = FactoryGirl.create :person, chapter: @chapter
    @shift = FactoryGirl.create :shift, positions: @person.positions, county: @person.counties.first
    @setting = Scheduler::NotificationSetting.create id: @person.id
  end

  after(:each) do
    Delorean.back_to_1985
  end

  describe "scheduler_periodic:send_invites" do

    before(:each) do
      @ass = FactoryGirl.create :shift_assignment, shift: @shift, person: @person, date: @chapter.time_zone.today.tomorrow
      @setting.update_attribute :send_email_invites, true
    end

    it "should send a reminder" do
      Scheduler::RemindersMailer.should_receive(:email_invite).and_return(stub :deliver => true)
      subject.invoke
      @ass.reload.email_invite_sent.should be_true
    end
  end

  ['email', 'sms'].each do |method|
    describe "scheduler_periodic:send_#{method}" do

      before(:each) do
        @ass = FactoryGirl.create :shift_assignment, shift: @shift, person: @person, date: @chapter.time_zone.today
        @setting.update_attribute "#{method}_advance_hours", 0
      end

      it "should send a reminder" do
        Delorean.time_travel_to @ass.local_start_time
        Scheduler::RemindersMailer.should_receive("#{method}_reminder".to_sym).and_return(stub :deliver => true)
        subject.invoke
        @ass.reload["#{method}_reminder_sent"].should be_true
      end
    end
  end

  ['email', 'sms'].each do |method|
    describe "scheduler_periodic:send_daily_#{method}" do

      before(:each) do
        @person2 = FactoryGirl.create :person, chapter: @chapter, positions: @person.positions, counties: @person.counties
        @ass = FactoryGirl.create :shift_assignment, shift: @shift, date: @chapter.time_zone.today, person: @person2
        @setting.update_attribute "#{method}_all_shifts_at", 10.hours.to_i
      end

      it "should send a reminder" do
        Delorean.time_travel_to @chapter.time_zone.now.change(hour: 10)

        Scheduler::RemindersMailer.should_receive("daily_#{method}_reminder".to_sym).and_return(stub :deliver => true)
        subject.invoke
        @setting.reload["last_all_shifts_#{method}"].should == @chapter.time_zone.today
      end
    end
  end
end