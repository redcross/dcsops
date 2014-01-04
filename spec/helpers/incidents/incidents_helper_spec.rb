require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Incidents::IncidentsHelper. For example:
#
# describe Incidents::IncidentsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Incidents::IncidentsHelper do
  before do
    helper.stub_chain(:resource, :to_param) { "IncidentURLParam" }
  end

  describe '#edit_link' do
    it "is empty when not editable" do
      helper.stub inline_editable?: false
      helper.edit_link('test').should be_blank
    end

    it "returns a link when editable" do
      helper.stub inline_editable?: true
      str = helper.edit_link('test-panel')
      str.should_not be_blank
      str.should be_a(ActiveSupport::SafeBuffer)
      str.should match('(edit)')
      str.should match('test-panel')
      str.should match('<a')
    end
  end

  describe '#passthrough_edit_link' do
    it "is just the title text when not editable" do
      helper.stub inline_editable?: false
      helper.passthrough_edit_link('test', 'Some Title').should == 'Some Title'
    end

    it "returns a link when editable" do
      helper.stub inline_editable?: true
      str = helper.passthrough_edit_link('test-panel', 'Some Title')
      str.should_not be_blank
      str.should be_a(ActiveSupport::SafeBuffer)
      str.should match('Some Title')
      str.should match('test-panel')
      str.should match('<a')
    end
  end

  describe '#version_ignore_fields' do
    it "should return an array" do
      %w(Incidents::Incident Incidents::DatIncident Incidents::EventLog Incidents::Case).each do |item_type|
        helper.version_ignore_fields(double item_type: item_type).should be_a(Array)
      end
    end
  end
  describe '#always_show_fields' do
    it "should return an array" do
      %w(Incidents::Incident Incidents::DatIncident Incidents::EventLog Incidents::Case).each do |item_type|
        helper.always_show_fields(double item_type: item_type).should be_a(Array)
      end
    end
  end

  describe '#format_change_value' do
    it "handles nil" do
      helper.format_change_value(double(:incident), '', nil).should == nil
    end
    it "returns a string as itself" do
      helper.format_change_value(double(:incident), '', 'Some String').should == 'Some String'
    end
    it "formats a date" do
      helper.format_change_value(double(:incident), '', DateTime.now).should be_a(String)
    end
    it "formats a YAML list for certain attributes" do
      yaml = YAML.dump ['service_one', 'service_two']
      helper.format_change_value(double(:incident), 'services', yaml).should == 'Service One and Service Two'
    end
    it "formats the cac number" do
      cac = Faker::Business.credit_card_number
      helper.format_change_value(double(:incident), 'cac_number', cac).should == "xxxx-xxxx-xxxx-#{cac.slice(-4, 4)}"
      helper.format_change_value(double(:incident), 'cac_number', '').should == ''
    end
  end
end
