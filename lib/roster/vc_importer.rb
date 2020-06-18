class Roster::VcImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def import_data(region, file)
    @region = region
    workbook = Spreadsheet.open(file)
    data_errs = nil
    Roster::Person.transaction do
      data_errs = import_member_data( workbook.worksheet("Contact")) { |str| yield str if block_given? }
    end
    {data_errs: data_errs}
  end
  add_transaction_tracer :import_data, category: :task

  private
  def import_member_data(sheet)
    (1..(sheet.last_row_index-1)).each do |row|
      break if sheet[row, 0].blank?
      id = sheet[row,23].to_i
      person = Roster::Person.where(region_id: @region, vc_id: id).first
      next unless person
      #cols = [:vc_member_number, nil, :first_name, nil, :last_name, nil, :email, :secondary_email, 
      #  :work_phone, :home_phone, :cell_phone, nil, nil, :alternate_phone,
      #  :address1, :address2, nil, nil, nil, :city, :state, :zip, nil, nil,
      #  :phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference]

      cols = [nil] * 24 + [:phone_1_preference, :phone_2_preference, :phone_3_preference, :phone_4_preference]

      cols.each_with_index do |col_name, idx|
        next unless col_name
        person.send "#{col_name}=".to_sym, sheet[row, idx]
      end
      person.save!

      yield "Member Data"
    end
  end

end