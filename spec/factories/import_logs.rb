# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :import_log do
    name "MyString"
    url "MyString"
    result "MyString"
    num_rows 1
    log "MyText"
    errors "MyText"
  end
end
