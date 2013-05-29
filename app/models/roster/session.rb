class Roster::Session < Authlogic::Session::Base
  authenticate_with Roster::Person

  def destroyed?; false; end
  #def self.primary_key; :email end
end