namespace :roster do

  task :update => :environment do
    Roster::Chapter.where{vc_username != nil}.each do |chapter|
      next unless vc_username.present?
      sh("rake roster:update_positions CHAPTER_ID=#{chapter.id}")
    end
  end

  task :update_positions => :environment do
    chapter = Roster::Chapter.find ENV['CHAPTER_ID']
    ImportLog.capture("UpdatePositions", "chapter-#{chapter.id}") do |logger, log|
      Roster::VcQueryToolImporter.new(logger, log).import(chapter, [:positions, :qualifications, :usage])
    end
  end

end