class LengthenResponderMessageBody < ActiveRecord::Migration
  def change
    change_column :incidents_responder_messages, :message, :text
  end
end
