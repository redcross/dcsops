require 'spec_helper'

describe Roster::SessionsController, :type => :controller do
  before do
    activate_authlogic
  end
  render_views

  context "#new" do

    it "should render" do
      get :new, legacy: true
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

  context "#create" do

    let!(:person) { FactoryGirl.create :person, username: 'test', password: 'test' }

    it "should not call the login service when we pass existing valid credentials" do
      expect(Roster::Session.find).to be_nil

      service = double :login_service
      expect(service).not_to receive :call
      expect(service).to receive :deferred_update

      expect(Roster::LoginService).to receive(:new).with('test', 'test').and_return(service)
      post :create, roster_session: {username: 'test', password: 'test'}
      expect(Roster::Session.find).not_to be_nil
    end

    it "should call the login service when we new valid credentials" do
      expect(Roster::Session.find).to be_nil

      service = double :login_service
      expect(service).to receive(:call) { person.update_attribute :password, 'test123'; true }
      expect(service).not_to receive :deferred_update

      expect(Roster::LoginService).to receive(:new).with('test', 'test123').and_return(service)
      post :create, roster_session: {username: 'test', password: 'test123'}
      expect(Roster::Session.find).not_to be_nil
    end

    it "should handle invalid credentials exception" do
      expect_any_instance_of(Roster::LoginService).to receive(:call).and_raise(Vc::Login::InvalidCredentials)
      post :create, roster_session: {username: 'test', password: 'test123'}
      expect(response).to be_success
      expect(flash.now[:error]).to include "credentials you provided are incorrect"
    end

    it "should handle connection timeout to VC" do
      expect(Roster::LoginService).to receive(:new).and_raise(Net::ReadTimeout)
      post :create, roster_session: {username: 'test', password: 'test'}
      expect(response).to be_success
      expect(flash.now[:error]).to include "error validating"
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