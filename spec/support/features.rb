module FeatureSpec
  extend ActiveSupport::Concern

  include TruncationStrategy

  included do
    def login_person(person)
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
        :uid => person.rco_id.to_s
      })

      # Have to go to the deep login page, not "/" and let redirect
      # because travis + capybara wasn't following the redirects correctly
      visit "/roster/session/new_rco?rco_idp_mode=dcs0"
      click_on "Log in with Red Cross Single Sign On"
    end

    def logout
      click_on "Logout"
    end

    self.use_transactional_tests = false

    before(:each) do |example|
      next if example.metadata[:logged_in] == false

      @person ||= FactoryGirl.create(:person, rco_id: rand(100000))
      login_person @person
    end

    after(:each) do |example|
      next if example.metadata[:logged_in] == false

      @person = nil
      logout
    end

    # For some incredibly stupid reason the Sauce gem aliases page to call 'selenium',
    # which clobbers the entire Capybara wrapper/driver system.  So, put it back and
    # hoppe this takes precedence.
    def page; Capybara.current_session; end
  end
end

RSpec.configure do |config|
  config.include Authlogic::TestCase
  config.include FeatureSpec, type: :feature
end