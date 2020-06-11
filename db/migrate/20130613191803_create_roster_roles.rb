class CreateRosterRoles < ActiveRecord::Migration

  class Position < ApplicationRecord
    self.table_name = 'roster_positions'
    has_and_belongs_to_many :roles, class_name: 'CreateRosterRoles::Role'
  end

  class Role < ApplicationRecord
    belongs_to :chapter
    self.table_name = 'roster_roles'
    serialize :role_scope
  end

  def up
    create_table :roster_roles do |t|
      t.references :chapter
      t.string :name
      t.string :grant_name
      t.text :role_scope

      t.timestamps
    end

    create_table :roster_positions_roles, id: false do |t|
      t.references :position
      t.references :role
    end

    say_with_time 'Migrating roles to Role model...' do
      Position.where{grants_role != nil}.each do |pos|
        role = Role.where(grant_name: pos.grants_role, role_scope: pos.role_scope, chapter_id: pos.chapter_id).first_or_initialize
        role.name ||= "#{pos.name} Role"
        role.save!
        pos.roles << role
        pos.save!
      end
    end

    remove_column :roster_positions, :grants_role
    remove_column :roster_positions, :role_scope
    remove_column :roster_positions, :is_county_admin
  end
end
