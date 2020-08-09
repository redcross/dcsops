class RemvoeBoundaryPolygonFromScopes < ActiveRecord::Migration
  def change
    remove_column :incidents_scopes, :boundary_polygon, :string, array:true
  end
end
