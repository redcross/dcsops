class AddVcStatusFieldsToPerson < ActiveRecord::Migration
  def change
    add_column :roster_people, :vc_is_active, :boolean, default: true
    add_column :roster_people, :gap_primary, :string
    add_column :roster_people, :gap_secondary, :string
    add_column :roster_people, :gap_tertiary, :string
    add_column :roster_people, :vc_last_login, :datetime
    add_column :roster_people, :vc_last_profile_update, :datetime
  end
end
