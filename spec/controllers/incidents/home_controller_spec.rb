require 'spec_helper'

describe Incidents::HomeController, :type => :controller do
  include LoggedIn
  before(:each) do
    @person.update_attribute :last_name, 'Laxson'
    FactoryGirl.create :incidents_scope, region: @person.region
  end

  describe "GET 'root'" do
    it "returns http success" do
      get 'root', region_id: @person.region.to_param
      expect(response).to be_success
    end
  end

end
