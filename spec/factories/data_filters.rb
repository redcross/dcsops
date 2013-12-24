# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_filter do
    model "MyString"
    field "MyString"
    pattern_raw "MyString"
  end
end
