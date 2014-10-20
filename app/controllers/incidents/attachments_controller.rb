class Incidents::AttachmentsController < Incidents::EditPanelController
  include RESTfulNotification
  belongs_to_incident
  self.panel_name = 'attachments'

  protected

  def notify resource
    Incidents::UpdatePublisher.new(@chapter, parent).publish_attachments
  end

  def resource_params
    request.get? ? [] : [params.require(:incidents_attachment).permit(:file, :attachment_type, :name, :description)]
  end
end