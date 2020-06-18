namespace :roster do

  task :update => :environment do
    Raven.capture do
      Roster::Region.where{vc_username != nil}.each do |region|
        next unless region.vc_username.present?
        begin
          sh("rake roster:update_positions REGION_ID=#{region.id}")
        rescue => e
          Raven.capture_exception e
        end
      end
    end
  end

  task :update_positions => :environment do
    Raven.capture do
      region = Roster::Region.find ENV['REGION_ID']
      Core::JobLog.capture("UpdatePositions", region) do |logger, log|
        Roster::VcQueryToolImporter.new(logger, log).import(region, [:positions, :qualifications, :usage])
      end
    end
  end

  task :geocode_users do
    Raven.capture do
      Roster::Person.where{vc_is_active==true}.where{(lat == nil) & (address !- nil)}.find_each {|p| p.save; sleep 0.1 }
    end
  end

end