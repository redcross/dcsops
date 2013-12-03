# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :price_list_item, :class => 'Incidents::PriceListItem' do
    item_class 2
    name "Some Price List Item"
    type nil
    unit_price {SecureRandom.random_number(10000) / 100.0}
  end
end
