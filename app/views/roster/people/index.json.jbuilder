json.array!(collection) do |roster_person|
  #json.extract! roster_person, :first_name, :last_name, :email, :home_phone, :cell_phone, :work_phone, :alternate_phone, :sms_phone, :phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference, :address1, :city, :state, :zip, :vc_id, :id
  json.extract! roster_person, :first_name, :last_name, :id
  json.url roster_person_url(roster_person, format: :json)
end