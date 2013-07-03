class CreatePartnersPartners < ActiveRecord::Migration
  def change
    create_table :partners_partners do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :lat
      t.decimal :lng

      t.timestamps
    end
  end
end
