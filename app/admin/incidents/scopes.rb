ActiveAdmin.register Incidents::Scope, as: 'Scope' do
  menu parent: 'Incidents'

  index do
    column :id
    column :url_slug
    column :name
    column :abbrev
    column :region
    column :region_ids
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :abbrev
      f.input :short_name
      f.input :url_slug
      f.input :region
    end
    f.inputs do
      f.input :regions, collection: Roster::Region.all, as: :check_boxes
    end
    f.inputs do
      # For some reason AA cares about the return value of this block, reduce is a shortcut for that
      f.object.class.serialized_columns.keys.map(&:to_sym).reduce(nil) do |_, c|
        f.input c
      end
    end
    f.inputs "Map" do
      f.input :boundary_polygon, as: :string_array
      f.template.render 'map', map_options: {bind_center: {lat: 'incidents_scope_incidents_map_center_lat', lng: 'incidents_scope_incidents_map_center_lng'}, bind_zoom: 'incidents_scope_incidents_map_zoom'}
    end
    f.actions
  end

  controller do
    helper Incidents::MapHelper
    defaults finder: :find_by_url_slug!
      def resource_params
      [params.fetch(resource_request_name, {}).permit!]
    end
  end

end
