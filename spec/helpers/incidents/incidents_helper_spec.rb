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
describe Incidents::IncidentsHelper, :type => :helper do
  before do
    allow(helper).to receive_message_chain(:resource, :to_param) { "IncidentURLParam" }
    allow(helper).to receive :edit_resource_dat_path do |*arg|
      "path_here?#{arg.first.to_query}"
    end
  end

  describe '#edit_link' do
    it "is empty when not editable" do
      helper.stub inline_editable?: false
      expect(helper.edit_link('test')).to be_blank
    end

    it "returns a link when editable" do
      helper.stub inline_editable?: true
      str = helper.edit_link('test-panel')
      expect(str).not_to be_blank
      expect(str).to be_a(ActiveSupport::SafeBuffer)
      expect(str).to match('(edit)')
      expect(str).to match('test-panel')
      expect(str).to match('<a')
    end
  end

  describe '#passthrough_edit_link' do
    it "is just the title text when not editable" do
      helper.stub inline_editable?: false
      expect(helper.passthrough_edit_link('test', 'Some Title')).to eq('Some Title')
    end

    it "returns a link when editable" do
      helper.stub inline_editable?: true
      str = helper.passthrough_edit_link('test-panel', 'Some Title')
      expect(str).not_to be_blank
      expect(str).to be_a(ActiveSupport::SafeBuffer)
      expect(str).to match('Some Title')
      expect(str).to match('test-panel')
      expect(str).to match('<a')
    end
  end

  describe '#version_ignore_fields' do
    it "should return an array" do
      %w(Incidents::Incident Incidents::DatIncident Incidents::EventLog Incidents::Case).each do |item_type|
        expect(helper.version_ignore_fields(double item_type: item_type)).to be_a(Array)
      end
    end
  end
  describe '#always_show_fields' do
    it "should return an array" do
      %w(Incidents::Incident Incidents::DatIncident Incidents::EventLog Incidents::Case).each do |item_type|
        expect(helper.always_show_fields(double item_type: item_type)).to be_a(Array)
      end
    end
  end

  describe '#format_change_value' do
    it "handles nil" do
      expect(helper.format_change_value(double(:incident), '', nil)).to eq(nil)
    end
    it "returns a string as itself" do
      expect(helper.format_change_value(double(:incident), '', 'Some String')).to eq('Some String')
    end
    it "formats a date" do
      expect(helper.format_change_value(double(:incident), '', DateTime.now)).to be_a(String)
    end
    it "formats a YAML list for certain attributes" do
      yaml = YAML.dump ['service_one', 'service_two']
      expect(helper.format_change_value(double(:incident), 'services', yaml)).to eq('Service One and Service Two')
    end
    it "formats the cac number" do
      cac = Faker::Business.credit_card_number
      expect(helper.format_change_value(double(:incident), 'cac_number', cac)).to eq("xxxx-xxxx-xxxx-#{cac.slice(-4, 4)}")
      expect(helper.format_change_value(double(:incident), 'cac_number', '')).to eq('')
    end
  end
end
