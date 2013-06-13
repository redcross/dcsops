class Roster::VcPositionsImporter
  def import_data(chapter, file)
    @chapter = chapter
    workbook = Spreadsheet.open(file)
    Roster::Person.transaction do

      Roster::PositionMembership.destroy_all_for_chapter(chapter)
      yield "Positions Cleared" if block_given?
      Roster::CountyMembership.destroy_all_for_chapter(chapter)
      yield "Counties Cleared" if block_given?

      import_qualification_data workbook.worksheet(0), 1, 0 do |s|
        yield s if block_given?
      end

    end
  end
  private
  def import_qualification_data(sheet, data_col, pos_col)

    counties = @chapter.counties.to_a.select{|c| c.vc_regex}
    positions = @chapter.positions.to_a.select{|c| c.vc_regex}

    person = nil

    errors = []

    puts "Have #{sheet.last_row_index-1} rows"

    (1..(sheet.last_row_index-1)).each do |idx|
      vc_id = sheet[idx, data_col].to_i
      pos_name = sheet[idx, pos_col]
      matched = false

      #pp "#{sheet[idx, data_col]} #{idx} #{vc_id}"

      unless person and person.vc_id == vc_id
        person = Roster::Person.find_by chapter_id: @chapter, vc_id: vc_id
        puts "Person for chap #{@chapter.id} vc_id #{vc_id} is #{person.inspect}"
        unless person
          errors << vc_id 
          next
        end

      end

      counties.each do |county|
        if county.vc_regex.match pos_name
          person.counties << county unless person.counties.include? county
          matched=true
          break
        end
      end

      positions.each do |position|
        if position.vc_regex.match pos_name
          person.positions << position unless person.positions.include? position
          matched=true
          break
        end
      end

      #puts "Warning, vc_id=#{vc_id} and person #{person.inspect} did not match qualification #{pos_name}" unless matched
      person.save!

      yield "Qual Data" if block_given?

    end

    puts errors.inspect

  end

end