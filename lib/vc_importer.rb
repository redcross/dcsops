class Roster::VcImporter
  def import_data(chapter, file)
    @chapter = chapter
    workbook = Spreadsheet.open(file)
    Roster::Person.transaction do
      import_member_data workbook.worksheet("Contact")
      # First Delete all the existing qualification data

      if workbook.worksheet("Positions") and workbook.worksheet("Qualifications")

        Roster::PositionMembership.destroy_all_for_chapter(chapter)
        Roster::CountyMembership.destroy_all_for_chapter(chapter)

        import_qualification_data workbook.worksheet("Positions"), 2, 3
        import_qualification_data workbook.worksheet("Qualifications"), 1, 3

      end
    end
  end
  private
  def import_member_data(sheet)
    (1..(sheet.last_row_index-1)).each do |row|
      break if sheet[row, 0].blank?
      id = sheet[row,23].to_i
      person = Roster::Person.where(chapter_id: @chapter, vc_id: id).first_or_initialize
      cols = [:vc_member_number, nil, :first_name, nil, :last_name, nil, :email, :secondary_email, 
        :work_phone, :home_phone, :cell_phone, nil, nil, :alternate_phone,
        :address1, :address2, nil, nil, nil, :city, :state, :zip, nil, nil,
        :phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference]

      cols.each_with_index do |col_name, idx|
        next unless col_name
        person.send "#{col_name}=".to_sym, sheet[row, idx]
      end
      person.vc_imported_at = Time.now
      person.save!
    end
  end
  def import_qualification_data(sheet, data_col, pos_col)

    counties = @chapter.counties.to_a.select{|c| c.vc_regex}
    positions = @chapter.positions.to_a.select{|c| c.vc_regex}

    person = nil

    (1..(sheet.last_row_index-1)).each do |idx|
      vc_id = sheet[idx, data_col].to_i
      pos_name = sheet[idx, pos_col]
      matched = false

      #pp "#{sheet[idx, data_col]} #{idx} #{vc_id}"

      unless person and person.vc_id == vc_id
        person = Roster::Person.find_by! chapter_id: @chapter, vc_id: vc_id
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

    end

  end

end