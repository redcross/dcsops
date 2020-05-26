require 'spec_helper'

describe "Logins", type: :feature, logged_in: false do

  it "Logs in legacy mode with valid credentials" do
    person = FactoryGirl.create :person, username: 'username', password: 'password', first_name: 'Bob', last_name: 'Boberson'

    visit "/?legacy=true"
    fill_in 'Username', with: 'username'
    fill_in 'Password', with: 'password'
    click_on 'Sign In'

    expect(page).to have_text(person.full_name)

    person.reload
    expect(person.username).to eq('username')
    expect(person.encrypted_password).not_to be_nil
  end

  it "Logs in legacy mode with invalid credentials" do
    person = FactoryGirl.create :person, username: 'username', password: 'password', first_name: 'Bob', last_name: 'Boberson'

    visit "/?legacy=true"
    fill_in 'Username', with: 'invalid_username'
    fill_in 'Password', with: 'invalid_password'
    click_on 'Sign In'

    expect(page).to have_text("The credentials you provided are incorrect.")
  end

  it "Logs in via single signon" do
    person = FactoryGirl.create(:person, rco_id: 123, first_name: "Test", last_name: "User")
    login_person person
    page.should have_text("Test User")
    person.destroy
  end

  it "Logs in via single signon with no database entry" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      :uid => '123'
    })
    visit "/"
    click_on "Log in with Red Cross Single Sign On"

    page.should have_text("Please Sign In")
  end

  it "Logs in and Logs out" do
    person = FactoryGirl.create(:person, rco_id: 123, first_name: "Test", last_name: "User")
    login_person person
    logout
    page.should_not have_text("Test User")
    page.should have_text("Log in with Red Cross Single Sign On")
    person.destroy
  end
end
