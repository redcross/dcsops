namespace :import_queue do
  task :work => :environment do
    logger = Rails.logger
    Raven.capture do
      sqs = Aws::SQS::Client.new
      s3 = Aws::S3::Client.new

      logger.info "Checking import queue..."

      queue_name = ENV['IMPORT_QUEUE_NAME']
      queue = (queue_name =~ /^http/) ? queue_name : sqs.get_queue_url(queue_name: queue_name).queue_url
      poller = Aws::SQS::QueuePoller.new(queue_name)

      poller.poll(wait_time_seconds: 10, idle_timeout: 10) do |envelope|
        message = JSON.parse envelope.body
        subject = message['message']['subject']
        endpoint = message['endpoint']

        logger.info "Import queue has item for #{endpoint}"

        region_code = subject.split("-")[0]
        region = Roster::Region.find_by(code: region_code)

        # Retrieve associated data
        if message['object']
          s3obj = s3.get_object({bucket: message['object']['bucket'], key: message['object']['key']})
          file = s3obj.body.read
          io = StringIO.new file
        end

        importer = case endpoint
        when 'cas-import-v1' then Incidents::CasImporter
        when 'vc-import-v1' then Roster::VcImporter
        when 'vc-import-v2' then Roster::VcPositionsImporter
        else
          raise "Unknown import endpoint #{endpoint}"
        end

        Core::JobLog.capture(importer.to_s) do |logger, counter|
          importer.new.import_data(region, io) do |step|
            counter.row!
            logger.info "Importing attachment #{counter.num_rows} @ #{step}..." if (counter.num_rows % 100) == 0
          end
        end

        # If we got this far, success!  Now clean up!
        s3obj.delete if s3obj
      end
    end
  end
end
