module Incidents
  class DisastersImporter

    def self.get_disasters chapter
      ImportLog.capture(self.to_s, "Get-#{chapter.id}") do |logger, counter|
        logger.level = 0
        query = Vc::DisasterManagement.new chapter.vc_username, chapter.vc_password, logger
        
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