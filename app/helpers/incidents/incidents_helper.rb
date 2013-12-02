module Incidents::IncidentsHelper

  def edit_link panel, title="(edit)", opts={}
    if inline_editable?
      url = edit_incidents_incident_dat_path(resource, panel_name: panel)
      link_to title, '#', {data: {edit_panel: url}}.merge(opts)
    else
      ""
    end
  end

  def passthrough_edit_link panel, title, opts={}
    if inline_editable?
      edit_link panel, title, opts
    else
      title
    end
  end
end
