json.extract! resource, :id, :first_name, :last_name, :email
json.extract! resource, :vc_is_active, :chapter_id, :vc_id, :vc_member_number
json.chapter_url roster_chapter_url(resource.chapter, format: :json)
json.deployments Incidents::Deployment.for_person(resource).includes{disaster} do |dep|
  json.extract! dep.disaster, :dr_number, :fiscal_year, :name, :vc_incident_id
  json.extract! dep, :gap, :group, :activity, :position, :qual, :id
  json.assign_date dep.date_first_seen
  json.release_date dep.date_last_seen
  json.url api_disaster_url(dep.disaster, format: :json)
end
json.positions resource.positions.includes{roles.role_scopes} do |position|
  json.name position.name
end
json.roles resource.positions.includes{roles.role_scopes}.flat_map{|p| p.roles.map(&:grant_name) }