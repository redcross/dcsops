require 'spec_helper'

describe RootController, :type => :controller do
  include LoggedIn

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'health'" do
    it "returns http success" do
      get 'health'
      expect(response).to be_success
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

    it "should return a link for no chapter" do
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should return a hash" do
      expect(controller.homepage_links).to be_a(Hash)
    end

    it "should return a link for the current chapter" do
      link.update_attributes chapter: @person.chapter
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should not return a link for another chapter" do
      other_chapter = FactoryGirl.create :chapter
      link.update_attributes chapter: other_chapter
      expect(controller.homepage_links.values.flatten).to match_array([])
    end

    it "should return a link where the current user has the correct role" do
      role = FactoryGirl.create :role, chapter: @person.chapter
      pos = FactoryGirl.create :position, roles: [role], chapter: @person.chapter
      @person.positions << pos
      @person.save

      link.update_attributes roles: [role]
      expect(controller.homepage_links.values.flatten).to match_array([link])
    end

    it "should not return a link where the current user does not have the right role" do
      role = FactoryGirl.create :role, chapter: @person.chapter
      link.update_attributes roles: [role]
      expect(controller.homepage_links.values.flatten).to match_array([])
    end

  end

end
