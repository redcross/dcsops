module Incidents::PubnubHelper
  def pubnub_page_setup(person)
    javascript_include_tag("https://cdn.pubnub.com/pubnub.min.js") <<
    javascript_tag(<<-JS)
      window.pubnub = PUBNUB.init({subscribe_key: #{PubnubClient.subscribe_key.to_json}});
    JS
  end

  def region_pubnub_setup region=nil
    region ||= current_region
    pubnub_setup region
  end

  def incidents_pubnub_setup incident=nil
    incident ||= resource
    pubnub_setup incident.region, incident
  end

  def pubnub_setup region, incident=nil
    return "" unless PubnubClient.subscribe_key.present? 

    incident_setup = "window.incidentInstantController.setIncident(#{incident.id.to_json});" if incident

    js = <<-JS
      $(function() {
        if (window.pubnub) {
          window.incidentInstantController = new IncidentInstantController(window.pubnub, "incident-updates");
          window.incidentInstantController.setRegion(#{region.id.to_json})
          #{incident_setup}
        }
      })
    JS
    pubnub_page_setup(current_user) <<
    javascript_tag(js)
  end


end