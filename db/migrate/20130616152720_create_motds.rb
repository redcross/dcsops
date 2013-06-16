class CreateMotds < ActiveRecord::Migration
  def change
    create_table :motds do |t|
      t.references :chapter, index: true
      t.datetime :begins
      t.datetime :ends
      t.string :cookie_code
      t.text :html
      t.string :dialog_class
      t.integer :cookie_version

      t.timestamps
    end
  end
end
