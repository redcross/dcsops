# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_scope, :class => 'Incidents::Scope' do
    association :chapter
    abbrev "ABA"
    short_name "ARCBA"
    name "ARC Bay Area"
    url_slug { |s| s.chapter.url_slug }
    config { {report_frequencies: 'weekly,daily', time_zone_raw: 'America/Los_Angeles' }}
  end
end
