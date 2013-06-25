require 'spec_helper'

describe Incidents::DispatchLogUpdated do
  before(:each) do
    FactoryGirl.create :dispatch_log
    @log = Incidents::DispatchLog.last
    @incident = FactoryGirl.create :incident, dispatch_log: @log
    @person = FactoryGirl.create :person
  end

  it "should notify someone subscribed to incident_dispatch" do
    @log.reload
    @log.delivered_at = 1.hour.ago
    @log.save

    Incidents::NotificationSubscription.create! person: @person, county: nil, notification_type: 'incident_dispatch'

    Incidents::IncidentsMailer.should_receive(:incident_dispatched).with(@incident, @person).and_return(stub :deliver => true)

    Incidents::DispatchLogUpdated.new(@log).save
  end

end