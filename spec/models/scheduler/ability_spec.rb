require 'spec_helper'

describe Scheduler::Ability do
  before(:each) do
    @person = FactoryGirl.create :person
    @position = @person.positions.first
  end

  let(:ability) { Scheduler::Ability.new(@person) }

  it "should be createable" do
    ability.should_not be_nil
  end

  pending "user tests"

  context "as county admin" do
    pending
  end
end