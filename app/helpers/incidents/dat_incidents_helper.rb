module Incidents::DatIncidentsHelper
  def error_keys(resource)
    map_errors(resource.errors).flat_map do |key|
      if key and assoc = resource.class.reflect_on_association( key)
        errs = resource.send(key).try(:errors)
        errs && map_errors(errs).map{|k| :"#{key}.#{k}"}
      end
    end.compact
  end

  def map_errors(errs)
    errs.map{|key, err| err.present? && key}
  end
end
