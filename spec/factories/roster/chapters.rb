# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chapter, :class => 'Roster::Chapter' do
    name 'Some Chapter'
    short_name 'ARCBA'
    code '12345'
  end
end
