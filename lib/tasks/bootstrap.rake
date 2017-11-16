require 'rubygems/user_interaction'
include Gem::UserInteraction

# Helper for executing a system command
def execute(command)
  puts "Executing: #{command}"
  system "#{command}"
end

# Ensure database.yml is copied from example file any time db:create is run
Rake::Task['db:load_config'].enhance(['bootstrap:db_config'])

# Make `rake bootstrap` run `rake bootstrap:all`
desc "Install gems, set up database, load seed data"
task :bootstrap do
  Rake::Task['bootstrap:all'].invoke
end

namespace :bootstrap do
  task :all do
    # Check for bundler
    print "-----> Checking for bundler... "
    has_bundler = !`which bundler`.empty?
    abort("\nCouldn't find bundler. Please install bundler first (gem install bundler).") unless has_bundler
    puts "✔"

    # Install dependencies
    puts "-----> Installing gems..."
    execute "bundle install --without production"

    # Set up database
    Rake::Task['db:create'].invoke

    # Prompt about destructive actions
    input = ask("Load database schema and seeds (potentially destructive action)? [yN]")

    # Load db schema and seeds if approved
    if input.upcase == 'Y'
      puts "-----> Loading database schema and seeds..."
      Rake::Task['db:schema:load'].invoke
      Rake::Task['db:seed'].invoke
    else
      puts "OK, skipping schema and seeds."
    end

    puts "-----> Finished. Run `rails server` to start the server."
  end

  desc "Install example database config file if one is not present"
  task :db_config do
    needs_config = `ls config/database.yml`.empty?
    if needs_config
      puts "-----> Installing example database config..."
      execute "cp -n config/database.yml.example config/database.yml"
    end
  end
end
