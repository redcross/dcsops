Bitly.config do |config|
  config.login = ENV['BITLY_USERNAME']
  config.api_key = ENV['BITLY_ACCESS_TOKEN']
  config.use_ssl = false
end