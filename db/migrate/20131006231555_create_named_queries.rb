class CreateNamedQueries < ActiveRecord::Migration
  def change
    create_table :named_queries do |t|
      t.string :name
      t.string :token
      t.text :parameters
      t.string :controller
      t.string :action

      t.timestamps
    end
  end
end
