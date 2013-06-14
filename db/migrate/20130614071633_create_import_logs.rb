class CreateImportLogs < ActiveRecord::Migration
  def change
    create_table :import_logs do |t|
      t.string :controller
      t.string :name
      t.string :url
      t.string :result

      t.string :message_subject
      t.string :file_name
      t.integer :file_size

      t.integer :num_rows
      t.text :log
      t.text :import_errors
      t.string :exception
      t.string :exception_message
      t.text :exception_trace

      t.float :runtime

      t.timestamps
    end
  end
end
