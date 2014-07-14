require 'spec_helper'

describe Incidents::ImportController, :type => :controller do

  describe "#import_dispatch_body_handler" do
    let(:importer) { double(:importer) }
    let(:log) { ImportLog.new }
    before(:each) { controller.stub importer: importer }

    it "Calls importer when no account is specified" do
      chapter = FactoryGirl.create :chapter, id: 1
      expect(importer).to receive(:import_data).with(chapter, an_instance_of(String))

      controller.import_dispatch_body_handler({}, "alksdfhjlakjd", log)
    end

    it "Calls importer when an account is specified" do
      chapter = FactoryGirl.create :chapter, id: 1
      chapter.update_attributes :directline_account_number => '1234'
      expect(importer).to receive(:import_data).with(chapter, an_instance_of(String))

      controller.import_dispatch_body_handler({}, "Test Account: 1234 Test", log)
    end

    it "Calls importer when an account is specified and default chapter exists" do
      chapter = FactoryGirl.create :chapter, id: 1
      c2 = FactoryGirl.create :chapter, id: 2
      c2.update_attributes :directline_account_number => '1234'
      expect(importer).to receive(:import_data).with(c2, an_instance_of(String))

      controller.import_dispatch_body_handler({}, "Test Account: 1234 Test", log)
    end

    it "Doesn't call importer when an account is specified but doesn't exist" do
      chapter = FactoryGirl.create :chapter, id: 1
      expect(importer).not_to receive(:import_data)
      expect {
        controller.import_dispatch_body_handler({}, "Test Account: 1234 Test", log)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end