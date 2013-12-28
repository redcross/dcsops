require 'csv'

class Roster::VcQueryToolImporter
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  attr_accessor :logger
  attr_accessor :row_counter

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
      qualifications: Roster::QualificationsImporter,
      usage: Roster::UsageImporter
    }
  end

  def import(chapter, queries=query_mappings.keys)
    client = VcQuery.new chapter.vc_username, chapter.vc_password
    client.logger = self.logger

    handlers = importer_mappings.slice(*queries).map do |name, klass|
      logger.info "Processing import for #{name}"
      if Rails.env.development? and true
        xls = Rails.cache.fetch "vc-query-#{name}-#{chapter.id}" do
          client.execute_query query_mappings[name]
        end
      else
        xls = client.execute_query query_mappings[name]          
      end

      csv = XlsToCsv.convert xls
      xls = nil

      handler = klass.new(csv, chapter)
      csv = nil; # Get rid of these 6MB+ objects
      handler.logger = logger
      handler.process { self.row_counter.row! if self.row_counter }
      handler
    end

    # This is the step that does most of the updates.  Defer this as long as possible so the transaction doesn't block
    # other activity.
    Roster::Person.transaction do
      logger.info "Beginning Bulk-update Transaction"

      if queries.include?(:positions) || queries.include?(:qualifications)
        Roster::PositionMembership.destroy_all_for_chapter(chapter)
        Roster::CountyMembership.destroy_all_for_chapter(chapter)
      end

      handlers.each {|h| h.after_import }

      logger.info "Done"
    end
  end
  add_transaction_tracer :import, category: :task
end

