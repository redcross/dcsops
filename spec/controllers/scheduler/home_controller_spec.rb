require 'spec_helper'

describe Scheduler::HomeController do
  include LoggedIn
  it "should render" do
    get :root
    response.code.should eq "200"
  end
end