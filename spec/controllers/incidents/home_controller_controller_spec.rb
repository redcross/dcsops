require 'spec_helper'

describe Incidents::HomeControllerController do

  describe "GET 'root'" do
    it "returns http success" do
      get 'root'
      response.should be_success
    end
  end

end
