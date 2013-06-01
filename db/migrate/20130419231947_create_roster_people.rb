class CreateRosterPeople < ActiveRecord::Migration
  def change
    create_table :roster_people do |t|
      t.references :chapter
      t.references :primary_county

      # These are all VC fields
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :secondary_email
      t.string :username

      t.string :home_phone
      t.string :cell_phone
      t.string :work_phone
      t.string :alternate_phone
      t.string :sms_phone

      t.string :phone_1_preference
      t.string :phone_2_preference
      t.string :phone_3_preference
      t.string :phone_4_preference

      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.integer :vc_id
      t.integer :vc_member_number
      # End VC fields

      t.integer :home_phone_carrier_id
      t.integer :work_phone_carrier_id
      t.integer :cell_phone_carrier_id
      t.integer :alternate_phone_carrier_id
      t.integer :sms_phone_carrier_id

      t.boolean :home_phone_disable
      t.boolean :work_phone_disable
      t.boolean :cell_phone_disable
      t.boolean :alternate_phone_disable
      t.boolean :sms_phone_disable

      t.string :encrypted_password
      t.string :password_salt
      t.binary :persistence_token
      t.timestamp :last_login

      t.timestamp :vc_imported_at
      t.timestamps
    end
  end
end
