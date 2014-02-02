class Incidents::CasImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def import_data(chapter, file)
    @chapters = Roster::Chapter.all
    workbook = Spreadsheet.open(file)

    inc_errors = []
    case_errors = []

    inc_errors = import_incident_data workbook.worksheet("Incidents") do |s|
      yield s if block_given?
    end
    case_errors = import_case_data workbook.worksheet("Cases") do |s|
      yield s if block_given?
    end

    [inc_errors, case_errors]
  end
  add_transaction_tracer :import_data, category: :task

  def num_threads
    0 #ActiveRecord::Base.connection_pool.spec.config[:pool] - 1
  end

  def import_incident_data(sheet)
    errors = []

    (1..(sheet.last_row_index-1)).each_slice(100).threach(num_threads) do |rows|

      ids = []
      ids_with_open = []

      ActiveRecord::Base.connection_pool.with_connection do |conn|

        Incidents::CasIncident.transaction do

          inc_numbers = rows.map{|row| sheet[row, 1]}
          incidents = Incidents::CasIncident.where(cas_incident_number: inc_numbers).group_by(&:cas_incident_number)

          rows.each do |row|
            break if sheet[row, 0].blank?
            id = sheet[row,1]
            puts id
            incident = incidents[id].try(:first) || Incidents::CasIncident.new(cas_incident_number: id)
            cols = [:dr_number, nil, :cas_name, :incident_date, nil, nil, nil, :county_name,
                    :cases_with_assistance, :cases_service_only, :cases_opened, :num_clients, :cases_closed, :cases_open, :chapter_code]

            cols.each_with_index do |col_name, idx|
              next unless col_name
              incident.send "#{col_name}=".to_sym, sheet[row, idx]
            end
            ids << incident.id
            ids_with_open << incident.id if incident.cases_open and incident.cases_open > 0
            if incident.chapter_code.present?
              incident.chapter = @chapters.detect{|ch| ch.cas_chapter_codes_array.include? incident.chapter_code }
            end      
            if !incident.save
              errors << incident
            end

            if block_given?
              yield "Incident Data"
            end
          end

          Incidents::CasIncident.where(id: ids).update_all last_import: Time.zone.now
          Incidents::CasIncident.where(id: ids_with_open).update_all last_date_with_open_cases: Date.current

        end

      end

    end

    errors
  end

  def import_case_data(sheet)
    errors = []

    (1..(sheet.last_row_index-1)).each_slice(100).threach(num_threads) do |rows|

      case_ids = []
      incident_ids = []
      incident = nil

      ActiveRecord::Base.connection_pool.with_connection do |conn|

        Incidents::CasIncident.transaction do

          inc_numbers = rows.map{|row| sheet[row, 0]}
          incidents = Incidents::CasIncident.where(cas_incident_number: inc_numbers).group_by(&:cas_incident_number)

          case_numbers = rows.map{|row| sheet[row, 1]}
          cases = Incidents::CasCase.where(case_number: case_numbers).group_by(&:case_number)

          rows.each do |row|
            next if sheet[row, 0].blank?
            incident_num = sheet[row,0]
            if incident.nil? || incident.cas_incident_number != incident_num
              incident = incidents[incident_num].try :first
            end
            #raise "Can't find incident #{incident_num}" unless incident
            case_num = sheet[row,1]

            if incident.nil?
              errors << {case_num => "No incident for #{incident_num}"}
              next
            end

            the_case = cases[case_num].try(:first) || Incidents::CasCase.new(cas_incident_id: incident, case_number: case_num)
            cols = [nil, nil, :num_clients, :family_name, :case_last_updated, :case_opened, :case_is_open, :language, :narrative, :address, :city, nil, :state,
                    :post_incident_plans, nil, nil, nil, nil, nil, nil, :notes]

            the_case.cas_incident = incident
            cols.each_with_index do |col_name, idx|
              next unless col_name
              case Incidents::CasCase.columns_hash[col_name.to_s].type
              when :boolean
                the_case.send "#{col_name}=".to_sym, sheet[row, idx]=='Open'
              else
                the_case.send "#{col_name}=".to_sym, sheet[row, idx]
              end
            end
            case_ids << the_case.id
            if !the_case.save
              errors << the_case
            else
              if incident.incident_id
                incident_ids << incident.incident_id
              end
            end
            if block_given?
              yield "Case Data #{incident_num} #{the_case.case_number}"
            end
          end

          Incidents::CasCase.where(id: case_ids).update_all last_import: Time.now
          Incidents::Incident.where(id: incident_ids).each{|i| i.update_from_cas}
        end
      end
    end

    errors
  end

end