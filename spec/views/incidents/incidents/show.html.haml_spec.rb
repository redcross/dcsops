require 'spec_helper'

describe "incidents/incidents/show" do
  let(:person) {FactoryGirl.create :person, last_name: 'Laxson'}
  let(:ability) {grant_role! 'incidents_admin', nil, person; Incidents::Ability.new person}

  before(:each) do
    view.controller.stub :current_ability => ability
    view.stub :current_user => person
    view.stub :current_chapter => person.chapter
    view.stub :resource_changes => []
    view.stub :close_resource_path => ''
    view.stub :mark_invalid_resource_path => ''
    view.stub :reopen_resource_path => ''
    view.stub :tab_authorized? => true
    view.stub :inline_editable? => false
    view.stub :resource_responder_messages_path do |*args|
      incidents_chapter_incident_responder_messages_path(person.chapter, @incident, *args)
    end
    view.stub :resource_path do |*args|
      incidents_chapter_incident_path(person.chapter, @incident)
    end
    view.stub :edit_resource_dat_path do |*args|
      edit_incidents_chapter_incident_dat_path(person.chapter, @incident)
    end
    view.stub :new_resource_event_log_path do |*args|
      new_incidents_chapter_incident_event_log_path(person.chapter, @incident, *args)
    end
    view.stub :edit_resource_event_log_path do |*args|
      edit_incidents_chapter_incident_event_log_path(person.chapter, @incident, *args)
    end
    view.stub :new_resource_attachment_path do |*args|
      new_incidents_chapter_incident_attachment_path(person.chapter, @incident, *args)
    end
  end

  def presenter(factory)
    Incidents::IncidentPresenter.new FactoryGirl.create(factory, chapter: person.chapter)
  end

  describe "open with no linked incidents" do
    has_resource(:incident) { presenter :incident  }

    it "should render" do
      render

      rendered.should match(@incident.incident_number)
      rendered.should match("Link to CAS Incident")
    end
  end

  describe "open with linked dat incident" do
    has_resource(:incident) { presenter :incident }

    it "should render" do
      dat = FactoryGirl.create :dat_incident, incident: @incident
      @incident.reload

      render

      rendered.should match(edit_incidents_chapter_incident_dat_path(@incident.chapter, @incident))
      rendered.should match('Demographics')
    end
  end

  describe "closed with linked dat incident" do
    has_resource(:incident) { presenter :closed_incident }

    it "should render" do
      render

      rendered.should match(edit_incidents_chapter_incident_dat_path(@incident.chapter, @incident))
      rendered.should match('Demographics')

      rendered.should match('Reopen')
      rendered.should match('Edit')
    end
  end

  describe "open and editable" do
    has_resource(:incident) { presenter :incident }

    it "should render" do
      view.stub :inline_editable? => true
      render

      rendered.should match('(edit)')
    end
  end

  describe "with linked cas incident" do
    has_resource(:incident) { presenter :incident }

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
    has_resource(:incident) { presenter :incident }

    it "should render" do
      @incident.update_attribute :cas_incident_number, "1-123456"

      render

      rendered.should match(@incident.cas_incident_number)
      rendered.should match("Link to CAS Incident")
      rendered.should_not match('Total Casework Clients')
    end
  end
end
