json.array!(collection) do |partner|
  json.extract! partner, :name, :id, :address1
  json.url partners_partner_url(partner, format: :json)
end