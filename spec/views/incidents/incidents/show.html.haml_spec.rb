require 'spec_helper'

describe "incidents/incidents/show" do
  let(:person) {FactoryGirl.create :person, last_name: 'Laxson'}
  let(:ability) {grant_role! 'incidents_admin', nil, person; Incidents::Ability.new person}

  before(:each) do
    view.controller.stub :current_ability => ability
    view.stub :current_user => person
    view.stub :resource_changes => []
  end

  describe "with no linked incidents" do
    has_resource(:incident) { FactoryGirl.create :incident }

    it "should render" do
      render

      rendered.should match(@incident.incident_number)
      rendered.should match("Link to CAS Incident")
    end
  end

  describe "with linked dat incident" do
    has_resource(:incident) { FactoryGirl.create :incident }

    it "should render" do
      dat = FactoryGirl.create :dat_incident, incident: @incident
      @incident.reload

      render

      rendered.should match(edit_incidents_incident_dat_path(@incident))
      rendered.should match('Demographics')
    end
  end

  describe "with linked cas incident" do
    has_resource(:incident) { FactoryGirl.create :incident }

    it "should render" do
      cas = FactoryGirl.create :cas_incident
      @incident.link_to_cas_incident cas
      @incident.reload

      render

      rendered.should match(cas.cas_incident_number)
      rendered.should match('Total Casework Clients')
      rendered.should_not match("Link to CAS Incident")
    end
  end

  describe "with cas number but no incident" do
    has_resource(:incident) { FactoryGirl.create :incident }

    it "should render" do
      @incident.update_attribute :cas_incident_number, "1-123456"

      render

      rendered.should match(@incident.cas_incident_number)
      rendered.should match("Link to CAS Incident")
      rendered.should_not match('Total Casework Clients')
    end
  end
end
