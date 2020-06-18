# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :roster_capability_scope, :class => 'Roster::CapabilityScope' do
    capability nil
    scope "MyString"
  end
end
