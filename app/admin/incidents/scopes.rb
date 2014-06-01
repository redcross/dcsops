ActiveAdmin.register Incidents::Scope, as: 'Scope' do
  menu parent: 'Incidents'

  index do
    column :id
    column :url_slug
    column :name
    column :abbrev
    column :chapter
    column :chapter_ids
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :abbrev
      f.input :short_name
      f.input :url_slug
      f.input :chapter
    end
    f.inputs do
      f.input :chapters, collection: Roster::Chapter.all, as: :check_boxes
    end
    f.inputs do
      # For some reason AA cares about the return value of this block, reduce is a shortcut for that
      f.object.class.serialized_columns.keys.map(&:to_sym).reduce(nil) do |_, c|
        f.input c
      end
    end
    f.actions
  end

  controller do
    defaults finder: :find_by_url_slug!
      def resource_params
      [params.fetch(resource_request_name, {}).permit!]
    end
  end

end
