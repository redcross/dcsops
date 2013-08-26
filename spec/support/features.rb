module Capybara
  class Session
    def cookies
      @cookies ||= begin
        secret = Rails.application.config.secret_token
        cookies = ActionDispatch::Cookies::CookieJar.new(secret)
        cookies.stub(:close!)
        cookies
      end
    end
  end
end

require File.expand_path("../authentication", __FILE__) # Provides LoggedIn module
module FeatureSpec
  extend ActiveSupport::Concern

  include LoggedIn

  included do
    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    before(:each) do
      request = ActionDispatch::Request.any_instance
      request.stub(:cookie_jar).and_return{ page.cookies }
      request.stub(:cookies).and_return{ page.cookies }

      @person ||= FactoryGirl.create :person
      @person.reset_persistence_token!
      @person.save!

      page.cookies['roster/person_credentials'] = "#{@person.persistence_token}::#{@person.id}"
    end

    after(:each) do
      @person = nil
    end

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end
  end
end

RSpec.configure do |config|
  config.include FeatureSpec, type: :feature
end