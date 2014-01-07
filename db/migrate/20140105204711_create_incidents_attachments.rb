class CreateIncidentsAttachments < ActiveRecord::Migration
  def change
    create_table :incidents_attachments do |t|
      t.references :incident, index: true, null: false
      t.string :attachment_type
      t.string :name
      t.text :description
      t.attachment :file
    end
  end
end
