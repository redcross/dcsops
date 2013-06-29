module AuthorizationRoles
  extend ActiveSupport::Concern
  included do
    def grant_role!(name, scope=nil, person=nil)
      person ||= @person

      role = Roster::Role.create! name: name, grant_name: name, chapter: person.chapter
      if scope
        scope.each do |s|
          role.role_scopes.create scope: s
        end
      end
      pos = Roster::Position.create! name:name, chapter: person.chapter
      pos.roles << role
      person.positions << pos
    end
  end
end

RSpec.configure do |config|
  config.include AuthorizationRoles
end