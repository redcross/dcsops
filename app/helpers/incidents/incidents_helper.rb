module Incidents::IncidentsHelper
  def inline_editable?
    true
  end

  def edit_link panel, title="(edit)", opts={}
    if inline_editable?
      link_to title, '#', {data: {edit_panel: panel}}.merge(opts)
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
