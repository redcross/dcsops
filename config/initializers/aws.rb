# Aws.config( :access_key_id => ENV['AWS_SECRET_KEY_ID'],
#             :secret_access_key => ENV['AWS_SECRET_KEY'])


Aws.config do |c|
  c.access_key_id = ENV['AWS_SECRET_KEY_ID']
  c.secret_access_key = ENV['AWS_SECRET_KEY']
end

