class AddPositionAbbreviations < ActiveRecord::Migration
  class Position < ApplicationRecord
    self.table_name = 'roster_positions'
  end

  def change
    add_column :roster_positions, :abbrev, :string

    say_with_time "Adding abbreviations to existing positions" do
      Position.all.each{|pos| pos.update_attribute(:abbrev, pos.name.gsub("DAT ", "").gsub(/[a-z]+\s?/, ""))}
    end
  end
end
