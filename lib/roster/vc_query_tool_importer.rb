require 'csv'

class Roster::VcQueryToolImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_accessor :logger
  attr_accessor :row_counter
  attr_reader :client

  def initialize(logger=nil, row_counter=nil)
    self.logger = logger || Rails.logger
    self.row_counter = row_counter
  end

  def queries
    [ '_DCSOps1a', '_DCSOps1b', '_DCSOps1c' ]
  end

  def importer_mappings
    {#members: MembersImporter, 
      positions: Roster::MemberPositionsImporter, 
    }
  end

  def get_query name
    if Rails.env.development?
      xls = Rails.cache.fetch "vc-query-#{name}" do
        client.execute_query name
      end
    else
      xls = client.execute_query name
    end
    CSV.parse(XlsToCsv.convert(xls))
  end

  def import()
    username = ENV['VC_QUERY_TOOL_USERNAME']
    password = ENV['VC_QUERY_TOOL_PASSWORD']
    @client = Vc::QueryTool.new username, password
    @client.logger = self.logger

    queries.each do |query|
      positions = get_query query

      grouped_positions = positions[1..-1].group_by { |p| p[2] }

      grouped_positions.each do |name, group|
        # Empty rows come in the spreadsheet, so we want to skip those
        next unless name

        region = Roster::Region.where(vc_hierarchy_name: name).first

        if region.nil?
          logger.error "Couldn't find a region configured with heirarchy name '#{name}'"
          next
        end

        handler = Roster::MemberPositionsImporter.new(positions, region, logger)
        handler.process { self.row_counter.row! if self.row_counter }
        Roster::Person.transaction do
          logger.info "Beginning Bulk-update Transaction"

          Roster::PositionMembership.destroy_all_for_region(region)
          Roster::ShiftTerritoryMembership.destroy_all_for_region(region)

          logger.info "Deleted existing memberships"

          handler.after_import

          logger.info "Done"
        end
      end
    end
  end
  add_transaction_tracer :import, category: :task
end

