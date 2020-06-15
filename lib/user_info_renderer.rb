class UserInfoRenderer
  def initialize(person, profile_keys, scopes)
    @person = person
    @profile_keys = profile_keys
    @scopes = scopes.map(&:name)
  end

  def to_hash
    [profile, vc_basic, vc_profile, deployments].compact.reduce(&:merge)
  end

  private

  attr_reader :person, :profile_keys, :scopes

  def profile
    mapping = {name: :full_name, given_name: :first_name, family_name: :last_name, preferred_username: :username,
      email: :email}
    attrs = mapping.map{|key, attr_name| 
      {key => person.send(attr_name)}
    }.reduce(&:merge).slice(*profile_keys)
  end

  def vc_basic
    if scopes.include? 'openid'
      {region: person.region_id, active: person.vc_is_active}
    end
  end

  def vc_profile
    if scopes.include? 'vc_profile'
      {
        positions: person.positions.map{|p| render_position p}
      }
    end
  end

  def render_position pos
    {id: pos.id, region_id: pos.region_id, name: pos.name, capabilties: pos.capability_memberships.map{|r| {name: r.capability.grant_name, scope: r.capability_scopes.map(&:scope)}}}
  end

  def deployments
    if scopes.include? 'deployments'
      { deployments: Incidents::Deployment.for_person(person).includes(:disaster).map{|d| render_deployment d} }
    end
  end

  def render_deployment d
    { dr_number: nil, dr_name: d.disaster.title, gap: d.gap, start_date: d.date_first_seen, end_date: d.date_last_seen}
  end
end