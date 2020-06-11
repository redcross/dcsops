class CreateRosterRoleScopes < ActiveRecord::Migration
  class Role < ApplicationRecord; 
    serialize :role_scope
    has_many :role_scopes
    self.table_name = "roster_roles"
  end
  class RoleScope < ApplicationRecord; 
    belongs_to :role
    self.table_name = "roster_role_scopes"
  end

  def change
    create_table :roster_role_scopes do |t|
      t.references :role, index: true
      t.string :scope

      t.timestamps
    end

    say_with_time "Moving role scopes" do
      Role.transaction do
        Role.find_each do |r|
          if r.role_scope and r.role_scope.respond_to?(:each)
            r.role_scope.each {|scope| r.role_scopes.create! scope: scope}
          end
        end
      end
    end

    remove_column :roster_roles, :role_scope
  end
end
