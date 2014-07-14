require 'spec_helper'

describe Scheduler::SendRemindersJob do
  let(:chapter) { mock_model Roster::Chapter, time_zone: Time.zone, id: SecureRandom.random_number }
  let(:person) { mock_model Roster::Person, chapter: chapter }
  let(:job) { Scheduler::SendRemindersJob.new(chapter.id).tap{|j| j.stub chapter: chapter } }

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  it 'enqueues for active chapters' do
    expect(Roster::Chapter).to receive(:all).and_return([chapter])
    job = double(:job)
    expect(job).to receive(:perform)
    expect(Scheduler::SendRemindersJob).to receive(:new).with(chapter.id).and_return(job)
    Scheduler::SendRemindersJob.enqueue
  end

  it "performs for all active reminders" do
    expect(job).to receive(:send_shift_reminder).with(:email_invite)
    expect(job).to receive(:send_shift_reminder).with(:email_reminder)
    expect(job).to receive(:send_shift_reminder).with(:sms_reminder)
    expect(job).to receive(:send_daily).with(:sms)
    expect(job).to receive(:send_daily).with(:email)

    job.perform
  end

  describe '#send_shift_reminder' do
    before(:each) do
      @ass = mock_model Scheduler::ShiftAssignment, person: person
    end

    ['email_invite', 'email_reminder', 'sms_reminder'].each do |method|
      it "should send the #{method}" do
        expect(Scheduler::ShiftAssignment).to receive("needs_#{method}").and_return([@ass])
        expect(Scheduler::RemindersMailer).to receive(method).with(@ass).and_return(double :deliver => true)
        expect(@ass).to receive(:update_attribute).with("#{method}_sent", true)
        job.send_shift_reminder method
      end
    end
  end

  describe '#send_daily' do
    before(:each) do
      @setting = mock_model(Scheduler::NotificationSetting, person: person)
    end

    ['email', 'sms'].each do |method|
      it "should send a #{method} reminder" do
        expect(Scheduler::NotificationSetting).to receive("needs_daily_#{method}").and_return([@setting])
        expect(Scheduler::RemindersMailer).to receive("daily_#{method}_reminder".to_sym).and_return(double :deliver => true)
        expect(@setting).to receive(:update_attribute).with("last_all_shifts_#{method}", chapter.time_zone.today)
        job.send_daily method
      end
    end
  end

  describe "integration", type: :mailer do
    after(:each) { Delorean.back_to_1985 }
    it "works all the way through for shift reminders" do
      assignment = FactoryGirl.create :shift_assignment
      assignment.person.update_attributes work_phone_carrier: FactoryGirl.create(:cell_carrier)
      setting = Scheduler::NotificationSetting.create person: assignment.person, sms_advance_hours: 3600, email_advance_hours: 3600

      Delorean.time_travel_to assignment.local_start_time
      expect(ActionMailer::Base.deliveries).to be_blank
      Scheduler::SendRemindersJob.enqueue
      expect(ActionMailer::Base.deliveries.size).to eq(2)
    end

    it "works all the way through for daily reminders" do
      person = FactoryGirl.create :person
      chapter = person.chapter
      person.update_attributes work_phone_carrier: FactoryGirl.create(:cell_carrier)
      setting = Scheduler::NotificationSetting.create person: person, email_all_shifts_at: 0, sms_all_shifts_at: 0

      expect(ActionMailer::Base.deliveries).to be_blank
      Scheduler::SendRemindersJob.enqueue
      expect(ActionMailer::Base.deliveries.size).to eq(2)

      setting.reload
      expect(setting.last_all_shifts_email).to eq(chapter.time_zone.today)
      expect(setting.last_all_shifts_sms).to eq(chapter.time_zone.today)
    end
  end
end