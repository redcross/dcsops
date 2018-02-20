class Roster::Session < Authlogic::Session::Base
  extend ActiveModel::Naming
  authenticate_with Roster::Person

  allow_http_basic_auth false

  def destroyed?; false; end
  #def self.primary_key; :email end
end