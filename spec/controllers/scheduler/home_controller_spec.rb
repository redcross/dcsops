require 'spec_helper'

describe Scheduler::HomeController do
  include LoggedIn
  render_views

  it "should render" do
    get :root
    response.code.should eq "200"
  end

  it "should render when the person has no counties" do
    @person.counties = []
    @person.save

    get :root
    response.should be_success
  end
end