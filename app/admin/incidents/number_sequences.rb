ActiveAdmin.register Incidents::NumberSequence, as: 'Number Sequence' do
  menu parent: 'Incidents'

  filter :name

  index do
    id_column
    column :name
    column :current_year
    column :current_number
    column :format
    column(:chapters) { |ns| safe_join(ns.chapters.map(&:name), tag(:br)) }
    actions
  end

  permit_params :name, :current_number, :current_year, :format

  controller do
    def collection
      @col ||= super.preload{chapters}
    end
  end
end
