# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :case_assistance_item, :class => 'Incidents::CaseAssistanceItem' do
    association :price_list_item
    quantity 1
  end
end
