require 'spec_helper'

describe Incidents::WeeklyReportJob do

  let(:chapter) { double :chapter, id: 1, time_zone: ActiveSupport::TimeZone['America/Los_Angeles'], incidents_report_send_at: 0 }
  let(:job) { Incidents::WeeklyReportJob.new(chapter.id).tap{|j| j.stub chapter: chapter } }
  let(:today) { chapter.time_zone.today }

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  describe "#current_send_date" do
    after(:each) { Delorean.back_to_1985 }
    it "is today if the cutoff is nil" do
      chapter.stub incidents_report_send_at: nil
      job.send(:current_send_date).should == today
    end
    it "is today if after the cutoff" do
      chapter.stub incidents_report_send_at: 28800
      Delorean.time_travel_to chapter.time_zone.now.change(hour: 10)
      job.send(:current_send_date).should == today
    end
    it "is yesterday if before the cutoff" do
      chapter.stub incidents_report_send_at: 28800
      Delorean.time_travel_to chapter.time_zone.now.change(hour: 4)
      job.send(:current_send_date).should == today.yesterday
    end
  end

  describe '#subscriptions' do
    let!(:sub_in_chapter) { FactoryGirl.create :notification_subscription }
    let!(:sub_outside_chapter) { FactoryGirl.create :notification_subscription }
    let(:chapter) { sub_in_chapter.person.chapter }
    let(:job) { Incidents::WeeklyReportJob.new(chapter.id) }
    it "returns a sub in the current chapter" do
      job.send(:subscriptions).should =~ [sub_in_chapter]
    end
  end

  describe '#deliver_subscription' do
    let(:person) { double :person, chapter: chapter }
    let(:sub) { double :subscription, person: person, range_to_send: (today-5)..today, update_attribute: nil }
    it "calls the mailer" do
      Incidents::ReportMailer.should_receive(:report_for_date_range).with(chapter, person, (today-5)..today) { double(:mailer).tap{|m| m.should_receive(:deliver)} }
      job.send(:deliver_subscription, sub)
      job.errors.should be_blank
    end
    it "updates the report sent date" do
      sub.should_receive(:update_attribute).with(:last_sent, today)
      Incidents::ReportMailer.should_receive(:report_for_date_range).and_return(double :mailer, deliver: true)
      job.send(:deliver_subscription, sub)
    end
    it "does not fail with an exception" do
      Incidents::ReportMailer.should_receive(:report_for_date_range).and_raise(Net::SMTPUnknownError)
      expect {
        job.send(:deliver_subscription, sub)
      }.to_not raise_error
      job.errors.should_not be_blank
    end
  end

  describe '#perform' do
    it "calls deliver_subscription with each subscription" do
      sub = double :subscription
      job.stub subscriptions: [sub]
      job.should_receive(:deliver_subscription).with(sub)
      job.perform
      job.count.should == 1
    end
  end

  describe '.enqueue' do
    it 'performs for each chapter' do
      chapter = FactoryGirl.create :chapter, incidents_report_send_automatically: true
      Incidents::WeeklyReportJob.should_receive(:new).with(chapter.id).and_return(double perform: true)
      Incidents::WeeklyReportJob.enqueue
    end
  end

  describe 'integration', type: :mailer do
    it 'works all the way through' do
      sub = FactoryGirl.create :notification_subscription
      chapter = sub.person.chapter
      chapter.update_attributes incidents_report_send_automatically: true

      ActionMailer::Base.deliveries.should be_blank
      Incidents::WeeklyReportJob.enqueue
      ActionMailer::Base.deliveries.should_not be_blank
    end
  end

end