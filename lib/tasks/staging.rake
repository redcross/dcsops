namespace :staging do
  TEMP_DB_NAME = "temp_staging_db"
  STAGING_APP = "arcdata-staging"

  task :copy_prod_db => :environment do
    puts "Downloading prod database backup"
    `dropdb --if-exists #{TEMP_DB_NAME}`
    `createdb -O #{ActiveRecord::Base.connection_config[:username]} #{TEMP_DB_NAME}`
    `heroku pg:backups:download -a arcdata`
    puts "Loading prod database backup into local temp database"
    `pg_restore -U #{ActiveRecord::Base.connection_config[:username]} -O -d #{TEMP_DB_NAME} latest.dump`
    `rm latest.dump`
  end

  task :truncate_prod_db => :copy_prod_db do
    puts "Remove unneeded records from local copy of production database"
    connection = ActiveRecord::Base.establish_connection(
      :adapter  => "postgresql",
      :host => ActiveRecord::Base.connection_config[:host],
      :username => ActiveRecord::Base.connection_config[:username],
      :password => ActiveRecord::Base.connection_config[:password],
      :database => TEMP_DB_NAME
    )
    truncate_tables = ["versions", "job_logs"]
    ActiveRecord::Base.connection.execute("TRUNCATE #{truncate_tables.join(", ")}")

    date_query_str = 2.months.ago.strftime("%Y-%m-%d")
    limit_tables = ["incidents_event_logs", "scheduler_shift_assignments", "incidents_responder_messages", "delayed_jobs"]
    limit_tables.each do |table|
      ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE created_at < '#{date_query_str}'")
    end
    (limit_tables + truncate_tables).each do |table|
      ActiveRecord::Base.connection.execute("VACUUM FULL #{table}")
    end
  end

  task :update_staging_db => :truncate_prod_db do
    puts "Update staging database from truncated local copy"
    `heroku pg:reset -a #{STAGING_APP}`
    `heroku pg:push #{TEMP_DB_NAME} DATA -a #{STAGING_APP}`
    `dropdb #{TEMP_DB_NAME}`
  end
end