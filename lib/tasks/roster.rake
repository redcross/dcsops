namespace :roster do
  task :import_email => [:environment] do
    require 'net/imap'

    path = File.join(Rails.root, 'config', 'email.yml')
    if File.file? path
      config = YAML.load(File.read(path))['vc_import']
      username = config['username']
      debug = config['debug']
      password = config['password']
      host = config['host']
    else
      # Use environment variables
      username = ENV['VC_IMPORT_USERNAME']
      password = ENV['VC_IMPORT_PASSWORD']
      host = ENV['VC_IMPORT_HOST']
      debug = (ENV['VC_IMPORT_DEBUG']=='true')
    end

    Net::IMAP.debug = debug

    imap = Net::IMAP.new(host, ssl: true)
    imap.login username, password

    imap.select 'Inbox'

    imap.uid_search(["NOT", "DELETED"]).each do |uid|
      # fetches the straight up source of the email for tmail to parse
      source   = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']

      Roster::ImportMailer.receive(source)

      break unless Rails.env.production?

      imap.uid_copy(uid, "[Gmail]/All Mail")
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end

    imap.expunge
    imap.logout
    imap.disconnect
  end

  task :update => :environment do
    Roster::Chapter.where{vc_username != nil}.each do |chapter|
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