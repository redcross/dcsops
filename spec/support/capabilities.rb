module AuthorizationCapabilities
  extend ActiveSupport::Concern
  included do
    def grant_capability!(name, scope=nil, person=nil)
      person ||= @person

      capability = Roster::Capability.create! name: name, grant_name: name
      pos = Roster::Position.create! name:name, region: person.region
      mem = Roster::CapabilityMembership.create! capability: capability, position: pos
      if scope
        scope.each do |s|
          mem.capability_scopes.create scope: s
        end
      end
      person.positions << pos
    end
  end
end

RSpec.configure do |config|
  config.include AuthorizationCapabilities
end