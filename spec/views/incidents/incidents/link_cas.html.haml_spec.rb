require 'spec_helper'

describe "incidents/incidents/link_cas" do
  let(:person) {FactoryGirl.create :person, last_name: 'Laxson'}
  let(:ability) {grant_role! 'incidents_admin', nil, person; Incidents::Ability.new person}

  before(:each) do
    view.controller.stub :current_ability => ability
    view.stub :current_user => person
    view.stub :current_chapter => person.chapter
    view.stub :cas_incidents_to_link => [FactoryGirl.create( :cas_incident)]
    view.stub :incidents_for_cas => [FactoryGirl.create( :incident)]
  end

  it "should render" do
    render
  end

end