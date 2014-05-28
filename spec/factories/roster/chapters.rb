# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chapter, :class => 'Roster::Chapter' do
    name 'Some Chapter'
    short_name 'ARCBA'
    code '12345'
    url_slug { "test#{SecureRandom.random_number 10000}"}

    time_zone_raw 'America/Los_Angeles'

    config({"incidents_map_zoom"=>"9", 
      "incidents_geocode_bounds"=>"36.5407938301337,-124.57967382718749,39.143091210253154,-119.52596288968749", 
      "incidents_map_center_lat"=>"37.81871654", 
      "incidents_map_center_lng"=>"-122.19014746", 
      "incidents_resources_tracked"=>"blankets,comfort_kits",
      "incidents_timeline_collect"=>"dat_received,dat_on_scene,dat_departed_scene",
      "incidents_timeline_mandatory"=>"dat_received,dat_on_scene,dat_departed_scene",
      "incidents_enabled_report_frequencies"=>"weekly,weekdays,daily",
      "scheduler_flex_day_start"=>"25200",
      "scheduler_flex_night_start"=>"68400"})
  end
end
