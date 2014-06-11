module Incidents::IncidentsHelper

  def edit_link panel, title="(edit)", opts={}
    if inline_editable?
      url = opts[:url] || edit_resource_dat_path(panel_name: panel)
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

  def version_ignore_fields(version)
    %w(id created_at updated_at incident_id) + case version.item_type
    when 'Incidents::Incident', 'Incidents::DatIncident'
      %w(lat lng)
    when 'Incidents::EventLog'
      %w(person_id)
    else
      []
    end
  end

  def format_change_value(base, name, val)
    case val
    when DateTime, Time, ActiveSupport::TimeWithZone
      val.in_time_zone.to_s :date_time # An ApplicationController filter automatically sets the current time zone for each request
    when String
      if name == 'cac_number' and val.present?
        "xxxx-xxxx-xxxx-" + val[-4..-1]
      elsif ['services', 'languages'].include? name and val.present?
        YAML.load(val).map(&:titleize).to_sentence
      else
        val
      end
    else val
    end
  end

  def always_show_fields(version)
    case version.item_type
    when 'Incidents::EventLog'
      %w(event)
    when 'Incidents::Case'
      %w(last_name unit)
    else
      []
    end
  end

  def missing_timeline_entries
    needed = resource.chapter.incidents_timeline_mandatory_array
    have = resource.event_logs.map(&:event)
    needed - have
  end

  def cas_event_button resource, message='View cases in CAS', **opts
    if resource.cas_event_id
      form_tag "https://#{resource.chapter.cas_host}/zf/clientsearch/find", method: :post do
        hidden_field_tag(:order_by, 'create_stamp_desc') <<
        hidden_field_tag('client[module][cas_event]', resource.cas_event_id) <<
        submit_tag(message, {class: 'btn btn-default'}.merge(opts))
      end
    end
  end

end
