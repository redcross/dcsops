ActiveAdmin.register Roster::Chapter, as: 'Chapter' do
  menu parent: 'Roster'

  filter :name
  filter :code

  actions :all, except: [:destroy]

  controller do
    def resource_params
      keys = [:name, :short_name, :code, :time_zone_raw, :vc_username, :vc_password, :vc_position_filter]
      keys = keys + resource_class.serialized_columns.values.map{|c| c.last.name.to_sym }
      request.get? ? [] : [params.require(:chapter).permit(*keys)]
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :short_name
      f.input :time_zone_raw
      f.input :vc_username
      f.input :vc_password, as: :string
      f.input :vc_position_filter

      # For some reason AA cares about the return value of this block, reduce is a shortcut for that
      f.object.class.serialized_columns.keys.map(&:to_sym).reduce(nil) do |_, c|
        f.input c
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
    default_actions
  end
end
