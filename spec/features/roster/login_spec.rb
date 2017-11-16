require 'spec_helper'

describe "View Timeline", type: :feature, logged_in: false do

  it "Logs in with valid credentials", vcr: {cassette_name: "Vc_Login/makes_a_query_with_uneditable_name"} do
    person = FactoryGirl.create :person, vc_id: 123123, first_name: 'Bob', last_name: 'Boberson' # Name needs to match the recorded cassette

    visit "/?legacy=true"
    fill_in 'Username', with: 'username'
    fill_in 'Password', with: 'password'
    click_on 'Sign In'

    expect(page).to have_text(person.full_name)

    person.reload
    expect(person.username).to eq('username')
    expect(person.encrypted_password).not_to be_nil
  end

  it "Logs in with invalid credentials", vcr: {cassette_name: "Vc_Login/incorrect_credentials/raises_an_error"} do
    person = FactoryGirl.create :person, vc_id: 123123, first_name: 'Bob', last_name: 'Boberson' # Name needs to match the recorded cassette

    visit "/?legacy=true"
    fill_in 'Username', with: 'invalid_username'
    fill_in 'Password', with: 'invalid_password'
    click_on 'Sign In'

    expect(page).to have_text("The credentials you provided are incorrect.")
    person.reload
    expect(person.username).to be_nil
    expect(person.encrypted_password).to be_nil
  end
end
