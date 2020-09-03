ActiveAdmin.register Incidents::ResponseTerritory, as: 'Response Territory' do
  menu parent: 'Incidents'

  actions :all, except: :destroy

  filter :region

  permit_params :region_id, :name, :enabled, :is_default, :dispatch_number, :non_disaster_number, :special_instructions, :dispatch_config_id, :shift_territory_ids => [], :counties => [], cities: [], zip_codes: []

  index do
    id_column
    column :region
    column :dispatch_config
    column :name
    column :enabled
    column :is_default
    actions
  end

  form do |f|
    f.inputs do
      configs = f.object.region ? Scheduler::DispatchConfig.for_region(f.object.region).order(:name) : Scheduler::DispatchConfig.order(:region_id, :name)
      f.input :region
      f.input :dispatch_config, collection: configs
      f.input :is_default
      f.input :name
      f.input :enabled
      f.input :dispatch_number
      f.input :non_disaster_number
      f.input :counties, as: :string_array
      f.input :cities, as: :string_array
      f.input :zip_codes, as: :string_array
      f.input :special_instructions
    end
    f.inputs 'Shift Territories' do
      f.input :shift_territories, as: :check_boxes, collection: available_shift_territories
    end
    f.actions
  end

  controller do
    def collection
      @coll ||= super.includes(:region)
    end

    def available_shift_territories
      if resource.region
        resource.region.shift_territories.enabled
      else
        Roster::ShiftTerritory.all.enabled
      end
    end
    helper_method :available_shift_territories
  end
end
