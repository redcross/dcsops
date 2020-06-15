ActiveAdmin.register Incidents::Territory, as: 'Territory' do
  menu parent: 'Incidents'

  actions :all, except: :destroy

  filter :chapter

  permit_params :chapter_id, :name, :enabled, :is_default, :dispatch_number, :non_disaster_number, :special_instructions, :dispatch_config_id, :calendar_county_ids => [], :counties => [], cities: [], zip_codes: []

  index do
    id_column
    column :chapter
    column :dispatch_config
    column :name
    column :enabled
    column :is_default
    actions
  end

  form do |f|
    f.inputs do
      configs = f.object.chapter ? Scheduler::DispatchConfig.for_chapter(f.object.chapter).order(:name) : Scheduler::DispatchConfig.order(:chapter_id, :name)
      f.input :chapter
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
    f.inputs 'Counties' do
      f.input :calendar_counties, as: :check_boxes, collection: available_counties
    end
    f.actions
  end

  controller do
    def collection
      @coll ||= super.includes(:chapter)
    end

    def available_counties
      if resource.chapter
        resource.chapter.counties
      else
        Roster::County.all
      end
    end
    helper_method :available_counties
  end
end
