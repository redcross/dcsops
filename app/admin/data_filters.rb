ActiveAdmin.register DataFilter do
  menu parent: 'System'

  controller do
    def resource_params
      return [] if request.get?
      [params.require('data_filter').permit(:model, :field, :pattern_raw)]
    end
  end
end