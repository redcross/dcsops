class RearrangeRoles < ActiveRecord::Migration
  class Role < ApplicationRecord
    self.table_name = :roster_roles
    has_and_belongs_to_many :positions
    has_many :role_memberships
    has_many :role_scopes
  end
  class Position < ApplicationRecord
    self.table_name = :roster_positions
    has_many :role_memberships
  end
  class RoleMembership < ApplicationRecord
    self.table_name = :roster_role_memberships
    has_many :role_scopes
    belongs_to :role
    belongs_to :position
  end
  class RoleScope < ApplicationRecord
    self.table_name = :roster_role_scopes
  end
  class HomepageLink < ApplicationRecord
    has_many :homepage_link_roles
    has_and_belongs_to_many :roles
  end
  class HomepageLinkRole < ApplicationRecord
    belongs_to :homepage_link
  end

  def change
    create_table :roster_role_memberships do |t|
      t.references :role
      t.references :position
      t.string :description
    end
    create_table :homepage_link_roles do |t|
      t.references :homepage_link
      t.string :role_scope
    end 
    add_column :roster_role_scopes, :role_membership_id, :integer

    say_with_time 'Updating HomepageLinks' do
      HomepageLink.includes(:roles).each do |hl|
        hl.roles.each do |r|
          hl.homepage_link_roles.create! role_scope: r.name
        end
      end
    end

    say_with_time 'Updating roles' do
      by_name = {}
      all_roles = Role.all.to_a
      all_roles.each do |r|
        global = by_name[r.grant_name]
        unless global
          global = by_name[r.grant_name] = Role.create! name: r.grant_name.titleize, grant_name: r.grant_name
        end

        positions = r.positions
        positions.each do |pos|
          mem = global.role_memberships.create! position: pos
          if r.role_scopes.present?
            mem.description = r.name
            mem.save!
          end
          r.role_scopes.each do |scope|
            mem.role_scopes.create! scope: scope.scope
          end
        end
      end

      all_roles.each{|r| r.delete}
    end

    remove_column :roster_role_scopes, :role_id
    remove_column :roster_roles, :chapter_id
    drop_table :roster_positions_roles
    drop_table :homepage_links_roster_roles
  end
end
