require 'uri'

class Idat::IncidentImporter
  def initialize(server_url)
    components = URI.split(server_url)
    db_name = components[5].gsub("/", '')
    components[3] = components[3].try(:to_i)
    components[5] = nil
    server_url = URI::Generic.build(components).to_s

    @server = CouchRest::Server.new(server_url)
    @db = @server.database(db_name)
  end

  def get_incident(incident_number, dat_incident)
    result = @db.view("views/all_incidents", key: incident_number)
    doc = result['rows'].first
    if doc
      map_doc(doc['value'], dat_incident) 
      map_doc(doc['value'], dat_incident.incident)  if doc
    end
  end

  def map_doc(doc, obj)
    attrs = doc.map{|k, v| [k.underscore, v]}
    attrs = Hash[attrs].slice(*(obj.attributes.keys - ['county']))
    obj.attributes = attrs
  end
end