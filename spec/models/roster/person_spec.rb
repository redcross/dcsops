require 'spec_helper'

describe Roster::Person, :type => :model do
  let(:chapter) {FactoryGirl.create :chapter}
  let(:person) {FactoryGirl.create :person, positions: [position], chapter: chapter}
  let(:position) {Roster::Position.create name: 'Test Position', chapter: chapter}
  let(:role) {Roster::Role.create name: 'Test Role', grant_name: grant_name}
  let!(:membership) { Roster::RoleMembership.create role: role, position: position}
  describe "#has_role" do
    let(:grant_name) { "test_grant" }

    before(:each) { role }

    it "should return true if it has a role without a scope" do
      expect(person.has_role( grant_name)).to be_truthy
      expect(person.has_role( grant_name + "x")).to be_falsey
    end

    it "should return true if it has a role with a scope" do
      membership.role_scopes.build scope: "test"
      membership.save!

      expect(person.has_role( grant_name)).to be_truthy
      expect(person.has_role( grant_name + "x")).to be_falsey
    end
  end

  describe "#scope_for_role" do
    let(:grant_name) { "test_grant" }

    before(:each) { role }

    it "should return empty if it doesn't have that role" do

      expect(person.scope_for_role( grant_name + "x")).to eq([])
    end

    it "should return the scopes if it has a role with a scope" do
      membership.role_scopes.build scope: "test"
      membership.role_scopes.build scope: "1"
      membership.save!

      expect(person.scope_for_role( grant_name)).to match_array(['test', 1])
    end

    it "should return county ids for scope if the scope is county_ids" do
      membership.role_scopes.build scope: "county_ids"
      membership.role_scopes.build scope: "424242"
      membership.save!

      c = person.counties.create name: 'Test County', chapter: chapter

      expect(person.scope_for_role( grant_name)).to match_array(person.county_ids + [424242])
    end
  end
end