require 'spec_helper'

describe Incidents::NotificationSubscription do
  let!(:chapter) { FactoryGirl.create :chapter, incidents_enabled_report_frequencies: 'weekly,weekdays,daily' }
  let(:person) { FactoryGirl.create :person, chapter: chapter}

  describe "type=report" do
    let(:notification_type) { 'report' }

    it "Should be creatable" do
      expect{
        sub = Incidents::NotificationSubscription.create person_id: person.id, notification_type: notification_type
      }.to change(Incidents::NotificationSubscription, :count).by(1)
    end

    it "Should provide a default frequency" do
      sub = Incidents::NotificationSubscription.create person_id: person.id, notification_type: notification_type
      sub.frequency.should == 'weekly'
    end

    it "Should validate frequency" do
      sub = Incidents::NotificationSubscription.create person_id: person.id, notification_type: notification_type
      sub.frequency = nil
      sub.should_not be_valid
    end
  end

  describe "scope to_send_on" do
    

    describe "frequency weekly" do
      let!(:subscription) { Incidents::NotificationSubscription.create! person: person, notification_type: 'report', frequency: 'weekly'}

      it "Should return a subscription that has never been sent" do
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
      end

      it "Should return a subscription that hasn't been sent for this week" do
        subscription.update_attribute :last_sent, Date.current.at_beginning_of_week-7
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
      end

      it "Should not return a subscription that has been sent this week" do
        subscription.update_attribute :last_sent, Date.current.at_beginning_of_week
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ []
      end

    end

    describe "frequency daily" do
      let!(:subscription) { Incidents::NotificationSubscription.create! person: person, notification_type: 'report', frequency: 'weekly'}

      it "Should return a subscription that has never been sent" do
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
      end

      it "Should return a subscription that hasn't been sent today" do
        subscription.update_attribute :last_sent, Date.current - 17
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
      end

      it "Should not return a subscription that has been sent today" do
        subscription.update_attribute :last_sent, Date.current
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ []
      end

    end

    describe "frequency weekdays" do
      let!(:subscription) { Incidents::NotificationSubscription.create! person: person, notification_type: 'report', frequency: 'weekdays'}

      after(:each) do
        Delorean.back_to_1985
      end

      it "Should return a subscription that has never been sent" do
        Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
      end

      describe "on a non-Monday weekday" do
        before(:each) do
          Delorean.time_travel_to Date.current.at_beginning_of_week
        end

        it "Should return a subscription that hasn't been sent today" do
          subscription.update_attribute :last_sent, Date.current - 1
          Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
        end

        it "Should not return a subscription that has been sent today" do
          subscription.update_attribute :last_sent, Date.current
          Incidents::NotificationSubscription.to_send_on(Date.current).should =~ []
        end
      end

      describe "on a Monday" do
        before(:each) do
          Delorean.time_travel_to chapter.time_zone.today.at_beginning_of_week
        end

        it "Should return a subscription that hasn't been sent since friday" do
          subscription.update_attribute :last_sent, Date.current - 3
          Incidents::NotificationSubscription.to_send_on(Date.current).should =~ [subscription]
        end

        it "Should not return a subscription that has been sent" do
          subscription.update_attribute :last_sent, Date.current
          Incidents::NotificationSubscription.to_send_on(Date.current).should =~ []
        end

      end

      describe "on a weekend" do
        before(:each) do
          Delorean.time_travel_to chapter.time_zone.today.at_beginning_of_week
        end

        it "Should not return a subscription that hasn't been sent since friday" do
          subscription.update_attribute :last_sent, Date.current - 3
          Incidents::NotificationSubscription.to_send_on(Date.current - 1).should =~ []
        end

      end

    end
  end

  describe "#range_to_send" do
    let(:sub) {Incidents::NotificationSubscription.new(notification_type: 'weekly', person: person)}
    let(:today) {chapter.time_zone.today}

    after(:each) do
      Delorean.back_to_1985
    end

    it "should send yesterday when a daily" do
      sub.frequency = 'daily'
      yesterday = today-1
      sub.range_to_send.should == (yesterday..yesterday)
    end

    it "should send yesterday when weekdays during the week" do
      Delorean.time_travel_to 'tuesday'
      yesterday = today-1
      sub.frequency = 'weekdays'
      sub.range_to_send.should == (yesterday..yesterday)
    end

    it "should send the weekend when weekdays on Monday" do
      Delorean.time_travel_to 'monday'
      yesterday = today-1
      sub.frequency = 'weekdays'
      sub.range_to_send.should == (yesterday-2..yesterday)
    end

    it "should send last week when a weekly subscription" do
      bow = today.at_beginning_of_week
      sub.frequency = 'weekly'
      sub.range_to_send.should == ((bow-7)..(bow-1))
    end

  end


end
