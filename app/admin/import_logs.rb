ActiveAdmin.register ImportLog, as: 'Import Logs' do
  menu parent: 'System'
  actions :index, :show

  index do
    column :id
    column :name, sortable: :name do |rec|
      link_to "#{rec.controller}##{rec.name}", scheduler_admin_import_log_path(rec)
    end
    column :result
    column :num_rows
    column :exception_message
    column :runtime, sortable: 'runtime' do |rec|
      rec.runtime && ("%0.3fs" % rec.runtime)
    end
    column :created_at
    column :updated_at
  end

  show do |r|
    attributes_table do
      row :id
      row :controller
      row :name
      row :result
      row :url
      row :message_subject
      row :file_name
      row :file_size
      row :num_rows
      row :runtime do
        r.runtime && ("%0.3fs" % r.runtime)
      end

      row :created_at
      row :updated_at
    end

    attributes_table do
      row :exception
      row :exception_message
      row :exception_trace do
        simple_format r.exception_trace
      end
    end

    attributes_table do
      row :import_errors do
        simple_format r.import_errors
      end
      row :import_log  do
        simple_format r.log
      end
    end
  end

  controller do
    def resource_params
      []
    end
  end
end
