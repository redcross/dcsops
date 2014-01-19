require 'csv'

class Roster::VcQueryToolImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_accessor :logger
  attr_accessor :row_counter
  attr_reader :chapter

  def initialize(logger=nil, row_counter=nil)
    self.logger = logger || Rails.logger
    self.row_counter = row_counter
  end

  def query_mappings
    {#members: 'Active Members', 
      positions: 'Active Members Positions', 
      qualifications: 'Active Members Qualifications', 
      usage: 'Active Members Usage'
    }
  end

  def importer_mappings
    {#members: MembersImporter, 
      positions: Roster::MemberPositionsImporter, 
    }
  end

  def get_query name
    if Rails.env.development? and true
      xls = Rails.cache.fetch "vc-query-#{name}-#{chapter.id}" do
        client.execute_query query_mappings[name]
      end
    else
      xls = client.execute_query query_mappings[name]          
    end
    CSV.parse(XlsToCsv.convert(xls))
  end

  def join_positions_and_qualifications
    positions = get_query('positions')
    qualifications = get_query('qualifications')

    pos_header = positions.delete_at(0)
    qual_header = qualifications.delete_at(0)

    pos_id = pos_header.index('account_id')
    pos_name_col = pos_header.index('position_name')

    qual_id = qual_header.index('account_id')
    qual_name_col = qual_header.index('qualification_name')

    mapped_quals = NestedHash.hash_set
    qualifications.each do |qual_row|
      name = qual_row[qual_name_col]
      id = qual_row[qual_id]
      mapped_quals[id] << name if name.present?
    end

    last_id = nil
    output = [pos_header]

    positions.each do |pos_row|
      id = pos_row[pos_id]
      if last_id != id
        quals = mapped_quals[id] || []
        quals.each do |qual_name|
          new_row = pos_row.dup
          new_row[pos_name_col] = qual_name
          output << new_row
        end
      end

      last_id = id

      output << pos_row
    end

    output
  end

  def join_positions_and_usage
    positions = join_positions_and_qualifications
    usage = get_query('usage')

    pos_header = positions.delete_at(0)
    usage_header = usage.delete_at(0)

    pos_id = pos_header.index('account_id')
    usage_id = usage_header.index('account_id')

    usage_column_names = %w(address1 address2 address3 address4 address5)
    usage_column_numbers = usage_column_names.map{|name| usage_header.index(name)}

    mapped_usage = Hash.new
    usage.each do |usage_row|
      id = usage_row[usage_id]
      cols = usage_column_numbers.map{|i| usage_row[i] }
      mapped_usage[id] = cols
    end

    pos_header.push(*usage_column_names)
    positions.each do |pos_row|
      id = pos_row[pos_id]
      usage_cols = mapped_usage[id] || Array.new(usage_column_numbers.size, '')
      pos_row.push(*usage_cols)
    end
    positions.insert 0, pos_header
    positions
  end

  def import(chapter, queries=query_mappings.keys)
    @chapter = chapter
    client = VcQuery.new chapter.vc_username, chapter.vc_password
    client.logger = self.logger

    positions = join_positions_and_usage

    handler = Roster::MemberPositionsImporter.new(positions, chapter, logger)
    handler.process { self.row_counter.row! if self.row_counter }
    Roster::Person.transaction do
      logger.info "Beginning Bulk-update Transaction"

      if queries.include?(:positions) || queries.include?(:qualifications)
        Roster::PositionMembership.destroy_all_for_chapter(chapter)
        Roster::CountyMembership.destroy_all_for_chapter(chapter)
      end

      logger.info "Deleted existing memberships"

      handler.after_import

      logger.info "Done"
    end
  end
  add_transaction_tracer :import, category: :task
end

