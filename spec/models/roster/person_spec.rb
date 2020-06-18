require 'spec_helper'

describe Roster::Person, :type => :model do
  let(:region) {FactoryGirl.create :region}
  let(:person) {FactoryGirl.create :person, positions: [position], region: region}
  let(:position) {Roster::Position.create name: 'Test Position', region: region}
  let(:capability) {Roster::Capability.create name: 'Test Capability', grant_name: grant_name}
  let!(:membership) { Roster::CapabilityMembership.create capability: capability, position: position}
  describe "#has_capability" do
    let(:grant_name) { "test_grant" }

    before(:each) { capability }

    it "should return true if it has a capability without a scope" do
      expect(person.has_capability( grant_name)).to be_truthy
      expect(person.has_capability( grant_name + "x")).to be_falsey
    end

    it "should return true if it has a capability with a scope" do
      membership.capability_scopes.build scope: "test"
      membership.save!

      expect(person.has_capability( grant_name)).to be_truthy
      expect(person.has_capability( grant_name + "x")).to be_falsey
    end
  end

  describe "#scope_for_capability" do
    let(:grant_name) { "test_grant" }

    before(:each) { capability }

    it "should return empty if it doesn't have that capability" do

      expect(person.scope_for_capability( grant_name + "x")).to eq([])
    end

    it "should return the scopes if it has a capability with a scope" do
      membership.capability_scopes.build scope: "test"
      membership.capability_scopes.build scope: "1"
      membership.save!

      expect(person.scope_for_capability( grant_name)).to match_array(['test', 1])
    end

    it "should return shift_territory ids for scope if the scope is shift_territory_ids" do
      membership.capability_scopes.build scope: "shift_territory_ids"
      membership.capability_scopes.build scope: "424242"
      membership.save!

      c = person.shift_territories.create name: 'Test Shift Territory', region: region

      expect(person.scope_for_capability( grant_name)).to match_array(person.shift_territory_ids + [424242])
    end
  end
end