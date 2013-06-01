require 'spec_helper'
require 'vc_importer'

if ENV['TEST_IMPORT']

  describe Roster::VCImporter do

    before :all do
      @file = File.open(File.join(Rails.root, "spec", "fixtures", "roster", "vcdata-sanitized.xls"), "r")
    end

    after :all do
      @file.close
    end

    before :each do
      @chapter = FactoryGirl.create :chapter

      @sf = FactoryGirl.create :county, name: 'SF', vc_regex_raw: 'San Francisco', chapter: @chapter

      @dat = FactoryGirl.create :position, name: 'DAT', vc_regex_raw: 'DAT', chapter: @chapter
    end

    let(:importer) { Roster::VCImporter.new }

    it "should import the data" do
      

      expect {
        importer.import_data @chapter, @file
      }.to_not raise_error

      p = Roster::Person.where(vc_id: 48514).first
      p.should_not be_nil

      p.counties.should include(@sf)
      p.positions.should include(@dat)
    end
    
  end

end