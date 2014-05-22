class Incidents::EventLogsController < Incidents::EditPanelController
  self.panel_name = 'timeline'
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident, optional: true
  defaults route_prefix: nil

  protected

  def collection
    @collection ||= begin
      coll = super.includes{incident}.where{chapter_id==my{current_chapter}}.order{event_time.desc}
      coll = coll.page(params[:page]) if paginate?
      coll
    end
  end

  def build_resource
    super.tap{|log| log.event_time ||= Time.current }
  end

  def resource_params
    [params.fetch(:incidents_event_log, {}).permit(:event, :event_time, :message, :source_id).merge(person_id: current_user.id, chapter_id: chapter_id)]
  end

  def paginate?
    params[:page] != 'all'
  end

  def chapter_id
    parent? ? parent.chapter_id : current_chapter.id
  end

  def smart_collection_url
    parent? ? parent_path : collection_path
  end
end