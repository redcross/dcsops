class CreateApiClients < ActiveRecord::Migration
  def change
    create_table :api_clients do |t|
      t.string :name
      t.string :app_token
      t.string :app_secret

      t.timestamps
    end
  end
end
