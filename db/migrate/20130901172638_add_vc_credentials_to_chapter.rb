class AddVcCredentialsToChapter < ActiveRecord::Migration
  def change
    add_column :roster_chapters, :vc_username, :string
    add_column :roster_chapters, :vc_password, :string
  end
end
