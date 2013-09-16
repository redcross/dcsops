json.extract! resource, :id, :username, :full_name, :first_name, :last_name, :email, :secondary_email, :address1, :address2, :city, :state, :zip, :lat, :lng, :vc_id, :vc_member_number, :created_at, :updated_at
json.url url_for(resource)
json.phones resource.phone_order
json.chapter resource.chapter, :name, :short_name, :id
json.positions resource.positions, :name, :abbrev, :id
json.counties resource.counties, :name, :abbrev, :id
json.roles resource.roles do |role|
  json.extract! role, :name, :grant_name
  json.role_scopes role.role_scopes.map(&:scope) if role.role_scopes.present?
end