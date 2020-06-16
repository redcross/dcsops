require 'spec_helper'
describe Roster::PeopleController, :type => :controller do
  render_views

  include LoggedIn

  describe '#show' do
    it "should succeed as html" do
      get :show, params: { id: @person.id }
      expect(response).to be_success
    end

    it "should succeed as json" do
      get :show, params: { id: @person.id, format: :json }
      expect(response).to be_success
      expect(JSON.parse(response.body)).not_to be_nil
    end
  end

end