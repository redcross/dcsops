require 'spec_helper'
#require 'vc_importer'

if ENV['TEST_IMPORT']

  describe Roster::VCImporter, :type => :model do

    before :all do
      @file = File.open(File.join(Rails.root, "spec", "fixtures", "roster", "vcdata-sanitized.xls"), "r")
    end

    after :all do
      @file.close
    end

    before :each do
      @region = FactoryGirl.create :region

      @sf = FactoryGirl.create :county, name: 'SF', vc_regex_raw: 'San Francisco', region: @region

      @dat = FactoryGirl.create :position, name: 'DAT', vc_regex_raw: 'DAT', region: @region
    end

    let(:importer) { Roster::VCImporter.new }

    it "should import the data" do
      

      expect {
        importer.import_data @region, @file
      }.to_not raise_error

      p = Roster::Person.where(vc_id: 48514).first
      expect(p).not_to be_nil

      expect(p.counties).to include(@sf)
      expect(p.positions).to include(@dat)
    end
    
  end

end