require 'spec_helper'

describe Incidents::WeeklyReportJob do

  let(:chapter) { double :chapter, id: 1, time_zone: ActiveSupport::TimeZone['America/Los_Angeles'] }
  let(:scope) { double :scope, id: 2, chapter: chapter, report_send_at: 0, time_zone: ActiveSupport::TimeZone['America/Los_Angeles'] }
  let(:job) { Incidents::WeeklyReportJob.new(chapter.id).tap{|j| j.stub scope: scope } }
  let(:today) { chapter.time_zone.today }

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  describe "#current_send_date" do
    after(:each) { Delorean.back_to_1985 }
    it "is today if the cutoff is nil" do
      allow(scope).to receive(:report_send_at).and_return(nil)
      expect(job.send(:current_send_date)).to eq(today)
    end
    it "is today if after the cutoff" do
      allow(scope).to receive(:report_send_at).and_return(28800)
      Delorean.time_travel_to scope.time_zone.now.change(hour: 10)
      expect(job.send(:current_send_date)).to eq(today)
    end
    it "is yesterday if before the cutoff" do
      allow(scope).to receive(:report_send_at).and_return(28800)
      Delorean.time_travel_to scope.time_zone.now.change(hour: 4)
      expect(job.send(:current_send_date)).to eq(today.yesterday)
    end
  end

  describe '#subscriptions' do
    let!(:sub_in_chapter) { FactoryGirl.create :report_subscription }
    let!(:sub_outside_chapter) { FactoryGirl.create :report_subscription }
    let(:scope) { sub_in_chapter.scope }
    let(:job) { Incidents::WeeklyReportJob.new(scope.id) }
    it "returns a sub in the current chapter" do
      expect(job.send(:subscriptions)).to match_array([sub_in_chapter])
    end
  end

  describe '#deliver_subscription' do
    let(:person) { double :person, chapter: chapter }
    let(:sub) { double :subscription, person: person, range_to_send: (today-5)..today, update_attribute: nil, scope: scope }
    it "calls the mailer" do
      expect(Incidents::ReportMailer).to receive(:report_for_date_range).with(scope, person, (today-5)..today) { double(:mailer).tap{|m| expect(m).to receive(:deliver)} }
      job.send(:deliver_subscription, sub)
      expect(job.errors).to be_blank
    end
    it "updates the report sent date" do
      expect(sub).to receive(:update_attribute).with(:last_sent, today)
      expect(Incidents::ReportMailer).to receive(:report_for_date_range).and_return(double :mailer, deliver: true)
      job.send(:deliver_subscription, sub)
    end
    it "does not fail with an exception" do
      expect(Incidents::ReportMailer).to receive(:report_for_date_range).and_raise(Net::SMTPUnknownError)
      expect {
        job.send(:deliver_subscription, sub)
      }.to_not raise_error
      expect(job.errors).not_to be_blank
    end
  end

  describe '#perform' do
    it "calls deliver_subscription with each subscription" do
      sub = double :subscription
      allow(job).to receive(:subscriptions).and_return([sub])
      expect(job).to receive(:deliver_subscription).with(sub)
      job.perform
      expect(job.count).to eq(1)
    end
  end

  describe '.enqueue' do
    it 'performs for each chapter' do
      scope = FactoryGirl.create :incidents_scope, report_send_automatically: true
      expect(Incidents::WeeklyReportJob).to receive(:new).with(scope.id).and_return(double perform: true)
      Incidents::WeeklyReportJob.enqueue
    end
  end

  describe 'integration', type: :mailer do
    it 'works all the way through' do
      sub = FactoryGirl.create :report_subscription
      sub.scope.update_attributes report_send_automatically: true

      expect(ActionMailer::Base.deliveries).to be_blank
      Incidents::WeeklyReportJob.enqueue
      expect(ActionMailer::Base.deliveries).not_to be_blank
    end
  end

end