class Incidents::DeploymentImporter
  def import_data(chapter, io)
    @chapter = chapter
    workbook = Spreadsheet.open(io)

    errs = []

    Incidents::Deployment.transaction do
      errs = import_people workbook.worksheets.first do |s|
        yield s if block_given?
      end
    end
    errs
  end

  def import_people(sheet)
    errors = []

    (5..(sheet.last_row_index-1)).each do |row|
      puts row
      next if sheet[row, 4].blank?
      id = sheet[row,4].to_i
      puts id

      dr_name = sheet[row, 0]
      gap = sheet[row, 1]

      person = Roster::Person.where(vc_member_number: id).first
      unless person
        errors << {name: sheet[row, 5], id: id}
        next
      end

      dep = Incidents::Deployment.where(person_id: person, dr_name: dr_name, gap: gap).first_or_initialize

      dep.date_first_seen ||= @chapter.time_zone.today
      dep.date_last_seen = @chapter.time_zone.today

      (dep.group, dep.activity, dep.position, dep.qual) = gap.split("/")

      dep.save!

      yield "Deployment Data" if block_given?
    end

    errors
  end

      
end