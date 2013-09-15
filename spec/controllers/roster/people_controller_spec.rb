require 'spec_helper'
describe Roster::PeopleController do
  render_views

  include LoggedIn

  describe '#show' do
    it "should succeed as html" do
      get :show, id: @person.id
      response.should be_success
    end

    it "should succeed as json" do
      get :show, id: @person.id, format: :json
      response.should be_success
      JSON.parse(response.body).should_not be_nil
    end
  end

end