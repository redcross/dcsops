class CreateRosterVcImportData < ActiveRecord::Migration
  def change
    create_table :roster_vc_import_data do |t|
      t.references :chapter, index: true
      t.json :position_data

      t.timestamps
    end
  end
end
