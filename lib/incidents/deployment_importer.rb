class Incidents::DeploymentImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def self.get_deployments(chapter)
    ImportLog.capture(self.to_s, "Get-#{chapter.id}") do |logger, counter|
      logger.level = 0
      query = Vc::QueryTool.new chapter.vc_username, chapter.vc_password, logger
      file = query.get_disaster_query '38613', {return_jid: 4942232, prompt0: chapter.vc_unit}, :csv
      StringIO.open file.body do |io|
        self.new.import_data(chapter, io, counter)
      end
    end
  end

  def import_data(chapter, io, counter)
    @chapter = chapter
    workbook = CSV.parse(io)

    errs = []

    Incidents::Deployment.transaction do
      errs = import_people workbook do |s|
        counter.row!
        yield s if block_given?
      end
    end
    errs
  end
  add_transaction_tracer :import_data, category: :task

  def import_people(sheet)
    errors = []

    sheet.each do |row|
      id = row[15].to_i

      dr_name = row[4]
      gap = row[20]

      person = Roster::Person.where(vc_member_number: id).first
      unless person
        errors << {name: row[16], id: id}
        next
      end

      number, name = dr_name.split " ", 2
      number.gsub! '-20', '-'
      number.strip!
      name.strip!
      fy = number.split('-').last.to_i + 2000

      disaster = Incidents::Disaster.find_or_initialize_by(name: name)
      disaster.dr_number = number
      disaster.fiscal_year = fy
      disaster.save!

      dep = Incidents::Deployment.find_or_initialize_by(person_id: person.id, disaster_id: disaster.id, gap: gap)
      dep.date_first_seen ||= @chapter.time_zone.today
      dep.date_last_seen = @chapter.time_zone.today
      dep.save!

      yield "Deployment Data" if block_given?
    end

    errors
  end

      
end