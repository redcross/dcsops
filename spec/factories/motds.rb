# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :motd do
    region nil
    begins nil
    ends nil
    cookie_code "MyString"
    html "MyText"
    dialog_class "MyString"
  end
end
