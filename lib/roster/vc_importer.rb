class Roster::VcImporter
  def import_data(chapter, file)
    @chapter = chapter
    workbook = Spreadsheet.open(file)
    data_errs = nil
    pos_errs = nil
    qual_errs = nil

    pos = Roster::VcPositionsImporter.new
    pos.chapter = chapter

    Roster::Person.transaction do
      data_errs = import_member_data( workbook.worksheet("Contact")) { |str| yield str if block_given? }
      # First Delete all the existing qualification data

      if !Rails.env.production? and workbook.worksheet("Positions") and workbook.worksheet("Qualifications")
      
        Roster::PositionMembership.destroy_all_for_chapter(chapter)
        Roster::CountyMembership.destroy_all_for_chapter(chapter)
      
        pos_errs = pos.import_qualification_data( workbook.worksheet("Positions"), 2, 3)  { |str| yield str if block_given? }
        qual_errs = pos.import_qualification_data( workbook.worksheet("Qualifications"), 1, 3) { |str| yield str if block_given? }
      
      end
    end
    {data_errs: data_errs, pos_errs: pos_errs, qual_errs: qual_errs}
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

      yield "Member Data"
    end
  end

end