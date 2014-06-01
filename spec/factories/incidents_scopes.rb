# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :incidents_scope, :class => 'Incidents::Scope' do
    association :chapter
    abbrev "MyString"
    short_name "MyString"
    name "MyString"
    url_slug { |s| s.chapter.url_slug }
  end
end
