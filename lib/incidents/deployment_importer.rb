class Incidents::DeploymentImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def import_data(chapter, io)
    @chapter = chapter
    workbook = CSV.parse(io)

    errs = []

    Incidents::Deployment.transaction do
      errs = import_people workbook do |s|
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

      dr_name = row[12]
      gap = row[13]

      person = Roster::Person.where(vc_member_number: id).first
      unless person
        errors << {name: row[16], id: id}
        next
      end

      number, name = dr_name.split " ", 2
      number.gsub! '-20', '-'

      dep = Incidents::Deployment.find_or_initialize_by(person_id: person.id, dr_name: name, gap: gap)

      dep.dr_number = number
      dep.date_first_seen ||= @chapter.time_zone.today
      dep.date_last_seen = @chapter.time_zone.today

      dep.save!

      yield "Deployment Data" if block_given?
    end

    errors
  end

      
end