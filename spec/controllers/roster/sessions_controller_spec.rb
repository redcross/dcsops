require 'spec_helper'

describe Roster::SessionsController, :type => :controller do
  before do
    activate_authlogic
  end
  render_views

  context "#new" do

    it "should render" do
      get :new, params: { legacy: true }
      expect(response).to be_success
    end

    context "when logged in" do
      include LoggedIn

      it "should redirect" do
        get :new
        expect(response).to be_redirect
      end

    end

  end

  context "#destroy" do

    let!(:person) { FactoryGirl.create :person, username: 'test', password: 'test' }

    it "destroys the session" do
      Roster::Session.create person
      expect(Roster::Session.find).not_to be_nil
      delete :destroy
      expect(Roster::Session.find).to be_nil
    end

  end

  context "#show" do
    it "redirects to new" do
      get :show
      expect(response).to be_redirect
    end
  end

end