require 'spec_helper'

describe Scheduler::HomeController, :type => :controller do
  include LoggedIn
  render_views

  it "should render" do
    get :root
    expect(response.code).to eq "200"
  end

  it "should render when the person has no shift territories" do
    @person.shift_territories = []
    @person.save

    get :root
    expect(response).to be_successful
  end
end