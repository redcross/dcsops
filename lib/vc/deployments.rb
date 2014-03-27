module Vc
  class Deployments
    def self.get_deployments(chapter)
      ImportLog.capture(self.to_s, "Get-#{chapter.id}") do |logger|
        logger.level = 0
        query = QueryTool.new chapter.vc_username, chapter.vc_password, logger
        file = query.get_disaster_query '38613', {return_jid: 4942232, prompt0: chapter.vc_unit}, :csv
        StringIO.open file.body do |io|
          Incidents::DeploymentImporter.new.import_data(chapter, io)
        end
      end
    end
  end
end
