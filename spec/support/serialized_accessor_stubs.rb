module SerializedAccessorStubs
  extend ActiveSupport::Concern

  included do
    before do
      # To get feature specs passing while SerializedColumns module is stubbed out,
      # I'm going to globally stub a couple that we call here (consolidating
      # them all here instead of sprinkling them all throughout the specs at
      # their point of use). They need to be # stubs on any instance since
      # they're used in feature specs where the object # used to serve the
      # request is not accessible to us in the spec.

      # global_log_spec.rb
      allow_any_instance_of(Roster::Chapter).to receive(:incidents_use_global_log).and_return(true)

      allow_any_instance_of(Incidents::Scope).to receive(:report_frequencies).and_return('weekly,weekdays,daily')
    end
  end
end

RSpec.configure do |config|
  config.include SerializedAccessorStubs, type: :feature
end
