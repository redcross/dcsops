json.array!(collection) do |resource|
  json.url resource_url(resource, format: :json)
  json.extract! resource, :id, :vc_id, :vc_member_number, :first_name, :last_name
end