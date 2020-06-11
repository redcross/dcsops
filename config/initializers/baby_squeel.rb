# Enable squeel compatibility mode. This is discouraged, but should be
# short-lived as we replace all squeel usage with vanilla ActiveRecord prior to
# Rails 6 upgrade.

BabySqueel.configure do |config|
  config.enable_compatibility!
end
