json.array!(@roster_cell_carriers) do |roster_cell_carrier|
  json.extract! roster_cell_carrier, :name, :sms_gateway
  json.url roster_cell_carrier_url(roster_cell_carrier, format: :json)
end