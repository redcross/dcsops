class RemoveVcRegexRaw < ActiveRecord::Migration
  def change
    remove_column :roster_shift_territories, :vc_regex_raw, :string
    remove_column :roster_positions, :vc_regex_raw, :string
  end
end
