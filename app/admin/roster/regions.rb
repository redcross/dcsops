ActiveAdmin.register Roster::Region, as: 'Region' do
  menu parent: 'Roster'

  filter :name
  filter :code

  actions :all, except: [:destroy]

  controller do
    def resource
      param = params[:id]
      @region ||= (end_of_association_chain.where(url_slug: param).first || end_of_association_chain.find(param))
    end

    def resource_params
      keys = [:name, :short_name, :code, :url_slug, :time_zone_raw, :vc_username, :vc_password, :vc_hierarchy_name, :vc_position_filter, :vc_unit, :incident_number_sequence_id]
      keys = keys + resource_class.serialized_columns.values.map{|c| c.last.name.to_sym }
      [params.fetch(resource_request_name, {}).permit(*keys)]
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :vc_unit
      f.input :short_name
      f.input :url_slug
      f.input :time_zone_raw
      f.input :vc_username
      f.input :vc_password, as: :string
      f.input :vc_hierarchy_name
      f.input :vc_position_filter
      f.input :incident_number_sequence

      # For some reason AA cares about the return value of this block, reduce is a shortcut for that
      f.object.class.serialized_columns.keys.map(&:to_sym).reduce(nil) do |_, c|
        opts = {}
        opts[:as] = :string if c.to_s.include? "password"
        opts[:as] = :time_offset if c.to_s.include? "scheduler_flex"
        opts[:midnight] = true if c.to_s.include? "scheduler_flex_night_start"
        f.input c, opts
      end
    end
    f.actions
  end

  index do
    column :id
    column :name
    column :code
    column :short_name
    column :time_zone_raw
    column :vc_username
    actions
  end
end
