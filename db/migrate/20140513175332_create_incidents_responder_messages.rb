class CreateIncidentsResponderMessages < ActiveRecord::Migration
  def change
    create_table :incidents_responder_messages do |t|
      t.references :chapter, index: true
      t.references :person, index: true
      t.references :incident
      t.references :responder_assignment
      t.references :in_reply_to
      t.string :direction
      t.string :local_number
      t.string :remote_number
      t.string :message
      t.boolean :acknowledged

      t.string :status

      t.timestamps
    end
  end
end
