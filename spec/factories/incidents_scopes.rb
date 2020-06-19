# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_scope, :class => 'Incidents::Scope' do
    association :region
    abbrev "ABA"
    short_name "ARCBA"
    name "ARC Bay Area"
    url_slug { |s| s.region.url_slug }
    report_frequencies 'weekly,daily'
    time_zone_raw 'America/Los_Angeles'
  end
end
