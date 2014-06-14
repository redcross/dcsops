require 'spec_helper'

describe Vc::Hours do

  let(:credentials) { double(username: (ENV['VC_USERNAME'] || 'username'), password: (ENV['VC_PASSWORD'] || 'password'))}
  let(:service) { Vc::Client.new credentials.username, credentials.password }

  it "submits hours", vcr: true do
    service.hours.submit_hours 48514, "Test Hours", 1.0
  end

end