# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :homepage_link do
    region nil
    name "Home Link"
    description "MyText"
    icon "icon-name"
    url "some url"
    group "Some Group"
    ordinal 1
    group_ordinal 1
    file ""
  end
end
