ActiveAdmin.register Incidents::Territory, as: 'Territory' do
  menu parent: 'Incidents'

  actions :all, except: :destroy

  filter :chapter

  permit_params :chapter_id, :name, :enabled, :is_default, :dispatch_number, :non_disaster_number, :special_instructions, :counties => [], cities: [], zip_codes: []

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
      f.input :chapter
      f.input :dispatch_config
      f.input :name
      f.input :enabled
      f.input :dispatch_number
      f.input :non_disaster_number
      f.input :counties, as: :string_array
      f.input :cities, as: :string_array
      f.input :zip_codes, as: :string_array
      f.input :special_instructions
    end
    f.actions
  end

  controller do
    def collection
      @coll ||= super.includes{chapter}
    end
  end
end
