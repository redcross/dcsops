class AddBoundaryPolygonToScopes < ActiveRecord::Migration
  def change
    add_column :incidents_scopes, :boundary_polygon, :string, array:true
  end
end
