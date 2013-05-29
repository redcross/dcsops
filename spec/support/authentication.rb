module LoggedIn
  extend ActiveSupport::Concern
  included do
    before(:each) do
      activate_authlogic
      @person ||=  FactoryGirl.create(:person)
      Roster::Session.create @person
    end
  end
end