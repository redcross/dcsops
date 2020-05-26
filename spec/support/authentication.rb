module LoggedIn
  extend ActiveSupport::Concern
  included do
    before(:each) do |example|
      next if example.metadata[:logged_in] == false
      activate_authlogic
      @person ||= FactoryGirl.create(:person)
      Roster::Session.create @person
    end
  end
end
