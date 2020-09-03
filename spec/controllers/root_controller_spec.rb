require 'spec_helper'

describe RootController, :type => :controller do
  include LoggedIn

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_successful
    end
  end

  describe "GET 'health'" do
    it "returns http success" do
      get 'health'
      expect(response).to be_successful
    end

    it "returns 500 when there's an error" do
      expect(ActiveRecord::Base.connection).to receive(:select_value) { raise "Database Problem!" }
      expect(Raven).to receive(:capture)
      get 'health'
      expect(response.status).to eq(500)
    end
  end

  describe "GET 'inactive'" do
    it "returns http forbidden and renders" do
      get 'inactive', format: :html
      expect(response).to be_forbidden
      expect(response).to render_template("inactive")
    end

    it "returns http forbidden and renders" do
      get 'inactive', format: :json
      expect(response).to be_forbidden
    end
  end

  describe "#homepage_links" do

    let!(:link) {FactoryGirl.create(:homepage_link)}

    it "should return a link for no region" do
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should return a hash" do
      expect(controller.homepage_links).to be_a(Hash)
    end

    it "should return a link for the current region" do
      link.update_attributes region: @person.region
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should not return a link for another region" do
      other_region = FactoryGirl.create :region
      link.update_attributes region: other_region
      expect(controller.homepage_links.values.flatten).to match_array([])
    end

    it "should return a link where the current user has the correct role" do
      capability = FactoryGirl.create :capability, grant_name: 'homepage_link'
      pos = FactoryGirl.create :position, region: @person.region
      mem = Roster::CapabilityMembership.create capability: capability, position: pos
      mem.capability_scopes.create! scope: 'test'
      @person.positions << pos
      @person.save

      link.roles.create! role_scope: 'test'
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should not return a link where the current user does not have the right role" do
      role = FactoryGirl.create :capability, grant_name: 'homepage_link'
      link.roles.create! role_scope: 'test'
      expect(controller.homepage_links.values.flatten).to match_array([])
    end

  end

end
