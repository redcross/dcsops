class Incidents::AttachmentsController < Incidents::EditPanelController
  self.panel_name = 'attachments'

  protected

  def resource_params
    request.get? ? [] : [params.require(:incidents_attachment).permit(:file, :attachment_type, :name, :description)]
  end
end