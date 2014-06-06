namespace :incidents_periodic do
  task :send_reminders => [:send_missing_incident_report]

  task :send_no_incident_report => :environment do
    Raven.capture do
      Incidents::RemindMissingReportJob.enqueue
    end
  end

  task :send_weekly_report => :environment do
    Raven.capture do
      Incidents::WeeklyReportJob.enqueue
    end
  end

  task :get_deployments => [:environment, :get_disasters] do
    Raven.capture do
      Roster::Chapter.where{vc_username != nil}.each do |chapter|
        next unless chapter.vc_username.present?
        begin
          Incidents::DeploymentImporter.get_deployments chapter
        rescue => e
          Raven.capture_exception e
        end
      end
    end
  end

  task :get_disasters => :environment do
    Raven.capture do
      Roster::Chapter.where{vc_username != nil}.each do |chapter|
        next unless chapter.vc_username.present?
        Incidents::DisastersImporter.get_disasters chapter
        #break # For now, this only needs to run for one chapter since it pulls national data
      end
    end
  end

  task :update_driving_distances => :environment do
    Raven.capture do
      Incidents::UpdateDrivingDistanceJob.new.perform
    end
  end
end