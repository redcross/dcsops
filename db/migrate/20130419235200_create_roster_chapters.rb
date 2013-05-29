class CreateRosterChapters < ActiveRecord::Migration
  def change
    create_table :roster_chapters do |t|
      t.string :name
      t.string :code
      t.string :short_name

      t.timestamps
    end
  end
end
