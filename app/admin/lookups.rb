ActiveAdmin.register Lookup do
  menu parent: 'System'

  form do |f|
    f.inputs do
      f.input :chapter
      f.input :scope, as: :assignable_select_admin
      f.input :name
      f.input :value
      f.input :ordinal
    end
    f.actions
  end

  controller do
    def resource_params
      return [] if request.get?
      [params.require('lookup').permit!]
    end
  end
end