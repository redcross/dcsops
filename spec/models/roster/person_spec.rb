require 'spec_helper'

describe Roster::Person do
  let(:chapter) {FactoryGirl.create :chapter}
  let(:person) {FactoryGirl.create :person, positions: [position], chapter: chapter}
  let(:position) {Roster::Position.create name: 'Test Position', chapter: chapter}
  let(:role) {position.roles.create name: 'Test Role', grant_name: grant_name, chapter: chapter}
  describe "#has_role" do
    let(:grant_name) { "test_grant" }

    before(:each) { role }

    it "should return true if it has a role without a scope" do
      person.has_role( grant_name).should be_true
      person.has_role( grant_name + "x").should be_false
    end

    it "should return true if it has a role with a scope" do
      role.role_scopes.build scope: "test"
      role.save!

      person.has_role( grant_name).should be_true
      person.has_role( grant_name + "x").should be_false
    end
  end

  describe "#scope_for_role" do
    let(:grant_name) { "test_grant" }

    before(:each) { role }

    it "should return empty if it doesn't have that role" do

      person.scope_for_role( grant_name + "x").should eq([])
    end

    it "should return the scopes if it has a role with a scope" do
      role.role_scopes.build scope: "test"
      role.role_scopes.build scope: "1"
      role.save!

      person.scope_for_role( grant_name).should =~ ['test', 1]
    end

    it "should return county ids for scope if the scope is county_ids" do
      role.role_scopes.build scope: "county_ids"
      role.role_scopes.build scope: "424242"
      role.save!

      c = person.counties.create name: 'Test County', chapter: chapter

      person.scope_for_role( grant_name).should =~ (person.county_ids + [424242])
    end
  end
end