module Incidents
  class DisastersImporter

    def self.get_disasters region
      Core::JobLog.capture(self.to_s, region) do |logger, counter|
        logger.level = 0
        query = Vc::DisasterManagement.new region.vc_username, region.vc_password, logger
        
        disasters = query.get_active_disasters
        self.new.import_national disasters, counter
      end
    end

    def import_national disasters, counter=nil
      disasters.each do |disaster|
        import_disaster disaster
        counter.row! if counter
      end
    end

    def import_disaster attrs
      disaster = Incidents::Disaster.find_by(vc_incident_id: attrs[:vc_incident_id])
      unless disaster
        disaster = Incidents::Disaster.find_or_initialize_by(name: attrs[:name])
      end

      disaster.update_attributes vc_incident_id: attrs[:vc_incident_id], name: attrs[:name], dr_number: attrs[:dr_number]
    end
  end
end