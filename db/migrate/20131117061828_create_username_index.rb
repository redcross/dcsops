class CreateUsernameIndex < ActiveRecord::Migration
  def change
    execute "CREATE INDEX index_roster_people_on_username ON roster_people ( LOWER(username) )"
  end
end
