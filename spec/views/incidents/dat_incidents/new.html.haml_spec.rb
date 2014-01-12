require 'spec_helper'

describe "incidents/dat_incidents/new" do
  let(:person) {FactoryGirl.create(:person)}
  has_resource(:dat_incident) {Incidents::DatIncident.new.tap{|d| d.build_incident chapter: person.chapter }}

  it "should render" do
    view.stub(:form_url).and_return("some_url")
    view.stub(:current_user => person)
    view.stub :current_chapter => person.chapter
    view.stub(:grouped_incident_types => [], :grouped_responder_roles => [])
    view.stub(:scheduler_service => double(:service, :scheduled_responders => [], :flex_responders => []))
    @dat_incident.completed_by = view.current_user

    render
  end
end
