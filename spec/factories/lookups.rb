# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lookup do
    chapter nil
    scope "MyString"
    name "MyString"
  end
end
