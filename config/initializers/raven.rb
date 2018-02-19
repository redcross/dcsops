Raven.configure do |config|
  config.excluded_exceptions += ['Cas::Client::InvalidCredentials']
end
