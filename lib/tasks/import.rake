namespace :import_queue do
  task :work => :environment do
    logger = Rails.logger
    Raven.capture do
      sqs = AWS::SQS.new
      s3 = AWS::S3.new

      logger.info "Checking import queue..."

      queue_name = ENV['IMPORT_QUEUE_NAME']
      queue = (queue_name =~ /^http/) ? sqs.queues[queue_name] : sqs.queues.named(queue_name)

      queue.poll(wait_time_seconds: 10, idle_timeout: 10) do |envelope|
        message = JSON.parse envelope.body
        subject = message['message']['subject']
        endpoint = message['endpoint']

        logger.info "Import queue has item for #{endpoint}"

        chapter_code = subject.split("-")[0]
        chapter = Roster::Chapter.find_by(code: chapter_code)

        # Retrieve associated data
        if message['object']
          bucket = s3.buckets[message['object']['bucket']]
          s3obj = bucket.objects[message['object']['key']]
          file = s3obj.read
          io = StringIO.new file
        end

        importer = case endpoint
        when 'cas-import-v1' then Incidents::CasImporter
        when 'vc-import-v1' then Roster::VcImporter
        when 'vc-import-v2' then Roster::VcPositionsImporter
        else
          raise "Unknown import endpoint #{endpoint}"
        end

        ImportLog.capture(importer.to_s, 'import') do |logger, counter|
          importer.new.import_data(chapter, io) do |step|
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
