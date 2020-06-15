json.extract! resource, :id, :first_name, :last_name, :email
json.extract! resource, :vc_is_active, :region_id, :vc_id, :vc_member_number
json.region_url roster_region_url(resource.region, format: :json)
json.deployments Incidents::Deployment.for_person(resource).includes(:disaster) do |dep|
  json.extract! dep.disaster, :dr_number, :fiscal_year, :name, :vc_incident_id
  json.extract! dep, :gap, :group, :activity, :position, :qual, :id
  json.assign_date dep.date_first_seen
  json.release_date dep.date_last_seen
  json.url api_disaster_url(dep.disaster, format: :json)
end
json.positions resource.positions do |position|
  json.name position.name
end
json.capabilities resource.positions.includes(capability_memberships: [:capability_scopes, :capability]).flat_map{|p| p.capability_memberships.map{|rm| rm.capability.grant_name } }
