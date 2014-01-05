module Incidents::DatIncidentsHelper
  def error_keys(resource)
    map_errors(resource.errors).flat_map do |key|
      if assoc = resource.class.reflect_on_association(key)
        val = resource.send(key)
        val && error_keys(val).map{|k| :"#{key}.#{k}"}
      else
        key
      end
    end.compact
  end

  def map_errors(errs)
    errs.map{|key, err| err.present? && key}.compact
  end

  def panel(name, form)
    render "panel_#{name}", f: form
  end
end
