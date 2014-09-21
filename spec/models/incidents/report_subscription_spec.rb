require 'spec_helper'

describe Incidents::ReportSubscription, :type => :model do
  let(:scope) { FactoryGirl.create :incidents_scope, report_frequencies: 'weekly,weekdays,daily'}
  let(:person) { FactoryGirl.create :person, chapter: scope.chapter}
  def today; scope.chapter.time_zone.today; end
  after(:each) { Delorean.back_to_1985}

  describe "type=report" do
    let(:report_type) { 'report' }

    it "Should be creatable" do
      expect{
        sub = Incidents::ReportSubscription.create person_id: person.id, report_type: report_type, scope: scope
      }.to change(Incidents::ReportSubscription, :count).by(1)
    end

    it "Should provide a default frequency" do
      sub = Incidents::ReportSubscription.create person_id: person.id, report_type: report_type, scope: scope
      expect(sub.frequency).to eq('weekly')
    end

    it "Should validate frequency" do
      sub = Incidents::ReportSubscription.create person_id: person.id, report_type: report_type, scope: scope
      sub.frequency = nil
      expect(sub).not_to be_valid
    end
  end

  describe "scope to_send_on" do
    

    describe "frequency weekly" do
      let!(:subscription) { Incidents::ReportSubscription.create! person: person, report_type: 'report', frequency: 'weekly', scope: scope}

      it "Should return a subscription that has never been sent" do
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([subscription])
      end

      it "Should return a subscription that hasn't been sent for this week" do
        subscription.update_attribute :last_sent, Date.current.at_beginning_of_week-7
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([subscription])
      end

      it "Should not return a subscription that has been sent this week" do
        subscription.update_attribute :last_sent, Date.current.at_beginning_of_week
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([])
      end

    end

    describe "frequency daily" do
      let!(:subscription) { Incidents::ReportSubscription.create! person: person, report_type: 'report', frequency: 'weekly', scope: scope}

      it "Should return a subscription that has never been sent" do
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([subscription])
      end

      it "Should return a subscription that hasn't been sent today" do
        subscription.update_attribute :last_sent, Date.current - 17
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([subscription])
      end

      it "Should not return a subscription that has been sent today" do
        subscription.update_attribute :last_sent, Date.current
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([])
      end

    end

    describe "frequency weekdays" do
      let!(:subscription) { Incidents::ReportSubscription.create! person: person, report_type: 'report', frequency: 'weekdays', scope: scope}

      it "Should return a subscription that has never been sent" do
        expect(Incidents::ReportSubscription.to_send_on(Date.current)).to match_array([subscription])
      end

      describe "on a non-Monday weekday" do
        before(:each) do
          Delorean.time_travel_to today.at_beginning_of_week+3
        end

        it "Should return a subscription that hasn't been sent today" do
          subscription.update_attribute :last_sent, today - 1
          expect(Incidents::ReportSubscription.to_send_on(today)).to match_array([subscription])
        end

        it "Should not return a subscription that has been sent today" do
          subscription.update_attribute :last_sent, today
          expect(Incidents::ReportSubscription.to_send_on(today)).to match_array([])
        end
      end

      describe "on a Monday" do
        before(:each) do
          Delorean.time_travel_to today.at_beginning_of_week
        end

        it "Should return a subscription that hasn't been sent since friday" do
          subscription.update_attribute :last_sent, today - 3
          expect(Incidents::ReportSubscription.to_send_on(today)).to match_array([subscription])
        end

        it "Should not return a subscription that has been sent" do
          subscription.update_attribute :last_sent, today
          expect(Incidents::ReportSubscription.to_send_on(today)).to match_array([])
        end

      end

      describe "on a weekend" do
        before(:each) do
          Delorean.time_travel_to scope.chapter.time_zone.today.at_beginning_of_week
        end

        it "Should not return a subscription that hasn't been sent since friday" do
          subscription.update_attribute :last_sent, today - 2
          expect(Incidents::ReportSubscription.to_send_on(today - 1)).to match_array([])
        end

      end

    end
  end

  describe "#range_to_send" do
    let(:sub) {Incidents::ReportSubscription.new(report_type: 'weekly', person: person, scope: scope)}

    it "should send yesterday when a daily" do
      sub.frequency = 'daily'
      yesterday = today-1
      expect(sub.range_to_send).to eq(yesterday..yesterday)
    end

    it "should send yesterday when weekdays during the week" do
      Delorean.time_travel_to 'tuesday'
      yesterday = today-1
      sub.frequency = 'weekdays'
      expect(sub.range_to_send).to eq(yesterday..yesterday)
    end

    it "should send the weekend when weekdays on Monday" do
      Delorean.time_travel_to 'monday'
      yesterday = today-1
      sub.frequency = 'weekdays'
      expect(sub.range_to_send).to eq(yesterday-2..yesterday)
    end

    it "should send last week when a weekly subscription" do
      bow = today.at_beginning_of_week
      sub.frequency = 'weekly'
      expect(sub.range_to_send).to eq((bow-7)..(bow-1))
    end

  end


end
