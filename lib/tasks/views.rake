desc "Update views from SQL"
task :update_views => :environment do
  views = Dir["#{Rails.root}/db/views/*.sql"].sort
  views.each do |v|
    sql = File.read v
    puts "Updating #{File.basename v}..."
    ActiveRecord::Base.connection.execute sql
  end
end
