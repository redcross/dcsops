# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :motd do
    chapter nil
    begins "2013-06-16 08:27:20"
    ends "2013-06-16 08:27:20"
    cookie_code "MyString"
    html "MyText"
    dialog_class "MyString"
    version 1
  end
end
