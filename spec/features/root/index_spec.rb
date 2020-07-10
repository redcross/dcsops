require 'spec_helper'

describe "Home Page", :type => :feature do
  it "should be viewable" do
    visit "/"
    page.should have_text "My Contact Info"
  end

  it "should prompt for editing details" do
    visit "/"
    page.should have_text "Text messaging not enabled"
  end

  it "should not prompt for editing details if user has phone" do
    @person.home_phone_disable = false
    @person.save!
    visit "/"
    page.should_not have_text "Text messaging not enabled"
  end
end
