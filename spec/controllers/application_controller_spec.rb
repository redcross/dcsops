require 'spec_helper'

describe ApplicationController, :type => :controller do
  include LoggedIn

  describe "Checks Active User" do

    controller do
      def index; render plain: 'success'; end
    end

    it 'Does not redirect if active' do
      get :index
      expect(response).to be_successful
    end

    it "Redirects if not active" do
      @person.update_attribute :vc_is_active, false

      get :index
      expect(response).to redirect_to('/inactive')
    end

    it "Does not redirect if has the always_active role" do
      @person.update_attribute :vc_is_active, false
      grant_capability! 'always_active'

      get :index
      expect(response).to be_successful
    end

  end

  describe "Impersonation" do

    let(:impersonated) { FactoryGirl.create(:person, region: @person.region) }

    it "should give the current user when asked" do
      expect(controller.current_user).to eq(@person)
    end

    it "should give the current user when impersonating and not authorized" do
      session[:impersonating_user_id] = impersonated.id

      expect(controller.impersonating_user).to be_nil
      expect(controller.current_user).to eq(@person)
    end

    it "should give the impersonated user when impersonating and authorized" do
      session[:impersonating_user_id] = impersonated.id
      controller.stub can_impersonate: true

      expect(controller.impersonating_user).to eq(impersonated)
      expect(controller.current_user).to eq(impersonated)
    end

    it "should check that the logged in user is authorized to impersonate" do
      expect_any_instance_of(AdminAbility).to receive(:can?).with(:impersonate, anything).and_return(false)

      expect(controller.can_impersonate(impersonated)).to be_falsey
    end


  end

end