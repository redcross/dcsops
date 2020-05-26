require 'spec_helper'

describe "First test", :type => :feature do
  it "Should do something" do

    #FactoryGirl.create(:person, rco_id: 12345, first_name: "Bob", last_name: "Boberson")

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      :uid => '12345'
    })
    visit "/"
    click_on "Log in with Red Cross Single Sign On"

    page.should have_text("Please Sign In")
  end
  it "Should do something else" do

    FactoryGirl.create(:person, rco_id: 12345, first_name: "Test", last_name: "User")

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      :uid => '12345'
    })
    visit "/"
    click_on "Log in with Red Cross Single Sign On"

    page.should have_text("Test User")
  end
end
