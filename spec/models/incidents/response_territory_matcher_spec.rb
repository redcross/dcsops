require 'spec_helper'

describe Incidents::ResponseTerritoryMatcher do

  it "matches a zip code" do
    terr = Incidents::ResponseTerritory.new zip_codes: ["12345"], counties: [], cities: []
    incident = FactoryGirl.build :incident_without_response_territory, zip: '12345'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :response_territory).from(nil).to(terr)
  end

  it "matches a city" do
    terr = Incidents::ResponseTerritory.new zip_codes: [], counties: [], cities: ["Minneapolis, MN"]
    incident = FactoryGirl.build :incident_without_response_territory, city: 'Minneapolis', state: 'MN'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :response_territory).from(nil).to(terr)
  end

  it "matches a county" do
    terr = Incidents::ResponseTerritory.new zip_codes: [], counties: ["Cook, IL"], cities: []
    incident = FactoryGirl.build :incident_without_response_territory, county: 'Cook', state: 'IL'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :response_territory).from(nil).to(terr)
  end

  it "matches county from the same state" do
    terr = Incidents::ResponseTerritory.new counties: ['Orange, CA']
    terr2 = Incidents::ResponseTerritory.new counties: ['Orange, NY']
    incident = FactoryGirl.build :incident_without_response_territory, county: 'Orange', state: 'CA'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr2, terr]).perform
    }.to change(incident, :response_territory).from(nil).to(terr)
  end

  it "prefers zip code to city" do
    terr = Incidents::ResponseTerritory.new cities: ['Orange, CA']
    terr2 = Incidents::ResponseTerritory.new zip_codes: ['55555']
    incident = FactoryGirl.build :incident_without_response_territory, county: 'Orange', state: 'CA', zip: '55555'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr, terr2]).perform
    }.to change(incident, :response_territory).from(nil).to(terr2)
  end

  it "matches prefers city to county" do
    terr = Incidents::ResponseTerritory.new counties: ['Orange, CA']
    terr2 = Incidents::ResponseTerritory.new cities: ['Disneyland, CA']
    incident = FactoryGirl.build :incident_without_response_territory, county: 'Orange', state: 'CA', city: 'Disneyland'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr, terr2]).perform
    }.to change(incident, :response_territory).from(nil).to(terr2)
  end

  it "gracefully handles failed matches" do
    terr = Incidents::ResponseTerritory.new counties: ['Orange, CA']
    incident = FactoryGirl.build :incident_without_response_territory, county: 'Neverland', state: 'CA'
    expect {
      Incidents::ResponseTerritoryMatcher.new(incident, [terr]).perform
    }.to_not change(incident, :response_territory)
  end
end
