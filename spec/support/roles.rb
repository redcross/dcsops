module AuthorizationRoles
  extend ActiveSupport::Concern
  included do
    def grant_role!(name, scope=nil, person=nil)
      person ||= @person

      role = Roster::Role.create! name: name, grant_name: name
      pos = Roster::Position.create! name:name, chapter: person.chapter
      mem = Roster::RoleMembership.create! role: role, position: pos
      if scope
        scope.each do |s|
          mem.role_scopes.create scope: s
        end
      end
      person.positions << pos
    end
  end
end

RSpec.configure do |config|
  config.include AuthorizationRoles
end