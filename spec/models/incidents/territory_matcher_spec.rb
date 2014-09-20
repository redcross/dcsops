require 'spec_helper'

describe Incidents::TerritoryMatcher do

  it "matches a zip code" do
    terr = Incidents::Territory.new zip_codes: ["12345"], counties: [], cities: []
    incident = FactoryGirl.build :incident_without_territory, zip: '12345'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :territory).from(nil).to(terr)
  end

  it "matches a city" do
    terr = Incidents::Territory.new zip_codes: [], counties: [], cities: ["Minneapolis, MN"]
    incident = FactoryGirl.build :incident_without_territory, city: 'Minneapolis', state: 'MN'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :territory).from(nil).to(terr)
  end

  it "matches a county" do
    terr = Incidents::Territory.new zip_codes: [], counties: ["Cook, IL"], cities: []
    incident = FactoryGirl.build :incident_without_territory, county: 'Cook', state: 'IL'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr]).perform
    }.to change(incident, :territory).from(nil).to(terr)
  end

  it "matches county from the same state" do
    terr = Incidents::Territory.new counties: ['Orange, CA']
    terr2 = Incidents::Territory.new counties: ['Orange, NY']
    incident = FactoryGirl.build :incident_without_territory, county: 'Orange', state: 'CA'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr2, terr]).perform
    }.to change(incident, :territory).from(nil).to(terr)
  end

  it "prefers zip code to city" do
    terr = Incidents::Territory.new cities: ['Orange, CA']
    terr2 = Incidents::Territory.new zip_codes: ['55555']
    incident = FactoryGirl.build :incident_without_territory, county: 'Orange', state: 'CA', zip: '55555'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr, terr2]).perform
    }.to change(incident, :territory).from(nil).to(terr2)
  end

  it "matches prefers city to county" do
    terr = Incidents::Territory.new counties: ['Orange, CA']
    terr2 = Incidents::Territory.new cities: ['Disneyland, CA']
    incident = FactoryGirl.build :incident_without_territory, county: 'Orange', state: 'CA', city: 'Disneyland'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr, terr2]).perform
    }.to change(incident, :territory).from(nil).to(terr2)
  end

  it "gracefully handles failed matches" do
    terr = Incidents::Territory.new counties: ['Orange, CA']
    incident = FactoryGirl.build :incident_without_territory, county: 'Neverland', state: 'CA'
    expect {
      Incidents::TerritoryMatcher.new(incident, [terr]).perform
    }.to_not change(incident, :territory)
  end
end
