module LoggedIn
  extend ActiveSupport::Concern
  included do
    before(:each) do
      next if example.metadata[:logged_in] == false
      activate_authlogic
      @logged_in_person = FactoryGirl.create(:person)
      @person ||= @logged_in_person
      Roster::Session.create @person
    end
  end
end