module Incidents::DatIncidentsHelper
  def error_keys(resource)
    map_errors(resource.errors).flat_map do |key|
      val = resource.send(key)

      case val
      when nil then []
      when Enumerable, ActiveRecord::Associations::CollectionProxy
        val.flat_map{|o| error_keys(o).map{|k| :"#{key}.#{k}"}}
      else
        if val.respond_to? :errors
          error_keys(val).map{|k| :"#{key}.#{k}"}
        else
          [key]
        end
      end + [key]
    end.compact
  end

  def map_errors(errs)
    errs.map{|key, err| err.present? && key}.compact
  end

  def panel(name, form)
    render "panel_#{name}", f: form
  end

  def check_valid_panel panel
    case panel
    when 'basic', 'damage_assessment', 'demographics', 'feeding',
          'housing', 'location', 'narrative', 'resources', 'services',
          'vehicles', 'fire', 'vacate'
      panel
    else
      raise ActiveRecord::RecordNotFound, "Unknown panel #{panel}"
    end
  end

  def tabs_to_render(f)
    tabs = ['form_basic', 'form_responders', 'form_services']
    if f.object.incident.chapter.incidents_report_advanced_details
      tabs.insert 1, 'form_details'
    end
    tabs
  end

  def tab_titles
    {'form_basic' => 'Basic', 'form_responders' => 'Responders', 'form_services' => 'Services', 'form_details' => 'Incident Details'}
  end
end
