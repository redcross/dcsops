json.array!(collection) do |resource|
  json.url resource_url(resource, format: :json)
  json.extract! resource, :id, :vc_id, :vc_member_number, :first_name, :last_name, :full_name
  if include_phones?
    json.phones do
      json.array! resource.phone_order do |phone|
        json.number phone[:number]
        json.label phone[:label]
      end
    end
  end
end