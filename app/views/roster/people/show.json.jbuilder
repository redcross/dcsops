json.extract! resource, :id, :username, :full_name, :first_name, :last_name, :email, :secondary_email, :address1, :address2, :city, :state, :zip, :lat, :lng, :vc_id, :vc_member_number, :created_at, :updated_at
json.url url_for(resource)
json.phones resource.phone_order
json.chapter resource.chapter, :name, :short_name, :id
json.positions resource.positions, :name, :abbrev, :id
json.counties resource.counties, :name, :abbrev, :id
json.roles resource.role_memberships do |membership|
  json.extract! membership, :name
  json.extract! membership.role, :grant_name
  json.role_scopes membership.role_scopes.map(&:scope) if membership.role_scopes.present?
end