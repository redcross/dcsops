namespace :roster do

  task :update => :environment do
    Raven.capture do
      Core::JobLog.capture("UpdatePositions") do |logger, log|
        Roster::VcQueryToolImporter.new(logger, log).import()
      end
    end
  end

  task :geocode_users do
    Raven.capture do
      Roster::Person.where{vc_is_active==true}.where{(lat == nil) & (address !- nil)}.find_each {|p| p.save; sleep 0.1 }
    end
  end

end