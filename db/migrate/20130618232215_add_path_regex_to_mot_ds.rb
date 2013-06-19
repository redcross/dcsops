class AddPathRegexToMotDs < ActiveRecord::Migration
  def change
    add_column :motds, :path_regex_raw, :string
  end
end
