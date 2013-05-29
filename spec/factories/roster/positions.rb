# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :position, :class => 'Roster::Position' do
    name 'Some Position'
  end
end
