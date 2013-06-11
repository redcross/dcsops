require 'spec_helper'

describe Incidents::HomeController do
  include LoggedIn
  before(:each) do
    @person.update_attribute :last_name, 'Laxson'
  end

  describe "GET 'root'" do
    it "returns http success" do
      get 'root'
      response.should be_success
    end
  end

end
