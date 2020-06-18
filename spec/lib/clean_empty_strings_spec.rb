require 'spec_helper'

describe CleanEmptyStrings do
  it 'converts empty strings to nil upon type case' do
    example_model = FactoryGirl.create(:homepage_link, name: "")
    expect(example_model.name).to be_nil
  end
end
