json.extract! resource, :id, :username, :full_name, :first_name, :last_name, :email, :secondary_email, :address1, :address2, :city, :state, :zip, :lat, :lng, :vc_id, :vc_member_number, :created_at, :updated_at
json.url url_for(resource)
json.phones resource.phone_order
json.region resource.region, :name, :short_name, :id
json.positions resource.positions, :name, :abbrev, :id
json.shift_territories resource.shift_territories, :name, :abbrev, :id
json.capabilities resource.capability_memberships do |membership|
  json.extract! membership, :name
  json.extract! membership.capability, :grant_name
  json.capability_scopes membership.capability_scopes.map(&:scope) if membership.capability_scopes.present?
end