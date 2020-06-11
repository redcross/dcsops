class CreateIncidentSequence < ActiveRecord::Migration
  class Chapter < ApplicationRecord
    self.table_name = 'roster_chapters'
    belongs_to :incident_number_sequence, class_name: 'Incidents::NumberSequence'
    include Core::SerializedColumns

    serialized_accessor :config, :incidents_sequence_year, :integer
    serialized_accessor :config, :incidents_sequence_number, :integer
    serialized_accessor :config, :incidents_sequence_format, :string
    serialized_accessor :config, :incidents_sequence_enabled, :boolean
  end

  def change
    create_table :incidents_number_sequences do |t|
      t.string :name
      t.integer :current_year
      t.integer :current_number
      t.string :format
    end

    add_column :roster_chapters, :incident_number_sequence_id, :integer

    Chapter.all.each do |ch|
      if ch.incidents_sequence_enabled
        seq = Incidents::NumberSequence.create! name: ch.name, current_year: ch.incidents_sequence_year, current_number: ch.incidents_sequence_number, format: ch.incidents_sequence_format
        ch.incident_number_sequence = seq;
      end

      ch.config_will_change!
      ch.config.delete_if{|k, v| %w(incidents_sequence_year incidents_sequence_enabled incidents_sequence_number incidents_sequence_format).include? k.to_s }
      ch.save!
    end
  end
end
