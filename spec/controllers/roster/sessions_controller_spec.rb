require 'spec_helper'

describe Roster::SessionsController do
  before do
    activate_authlogic
  end
  render_views

  context "#new" do

    it "should render" do
      get :new
      response.should be_success
    end

    context "when logged in" do
      include LoggedIn

      it "should redirect" do
        get :new
        response.should be_redirect
      end

    end

  end

  context "#create" do

    let!(:person) { FactoryGirl.create :person, username: 'test', password: 'test' }

    it "should not call the login service when we pass existing valid credentials" do
      Roster::Session.find.should be_nil

      service = double :login_service
      service.should_not_receive :call
      service.should_receive :deferred_update

      Roster::LoginService.should_receive(:new).with('test', 'test').and_return(service)
      post :create, roster_session: {username: 'test', password: 'test'}
      Roster::Session.find.should_not be_nil
    end

    it "should call the login service when we new valid credentials" do
      Roster::Session.find.should be_nil

      service = double :login_service
      service.should_receive(:call).and_return { person.update_attribute :password, 'test123'; true }
      service.should_not_receive :deferred_update

      Roster::LoginService.should_receive(:new).with('test', 'test123').and_return(service)
      post :create, roster_session: {username: 'test', password: 'test123'}
      Roster::Session.find.should_not be_nil
    end

    it "should handle invalid credentials exception" do
      Roster::LoginService.any_instance.should_receive(:call).and_raise(Vc::Login::InvalidCredentials)
      post :create, roster_session: {username: 'test', password: 'test123'}
      response.should be_success
      flash.now[:error].should include "credentials you provided are incorrect"
    end

    it "should handle connection timeout to VC" do
      Roster::LoginService.should_receive(:new).and_raise(Net::ReadTimeout)
      post :create, roster_session: {username: 'test', password: 'test'}
      response.should be_success
      flash.now[:error].should include "error validating"
    end

  end

  context "#destroy" do

    let!(:person) { FactoryGirl.create :person, username: 'test', password: 'test' }

    it "destroys the session" do
      Roster::Session.create person
      Roster::Session.find.should_not be_nil
      delete :destroy
      Roster::Session.find.should be_nil
    end

  end

  context "#show" do
    it "redirects to new" do
      get :show
      response.should be_redirect
    end
  end

end