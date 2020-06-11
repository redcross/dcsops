require 'spec_helper'

describe Incidents::ImportController, :type => :controller do

  describe "#import_dispatch_v1" do
    let(:importer) { double(:importer) }
    let(:log) { Core::JobLog.new }
    before(:each) { controller.stub importer: importer }

    it "Calls importer when no account is specified" do
      region = FactoryGirl.create :region, id: 1
      expect(importer).to receive(:import_data).with(region, an_instance_of(String))

      controller.import_dispatch_v1({ "body" => "alksdfhjlakjd" }, log)
    end

    it "Calls importer when an account is specified" do
      region = FactoryGirl.create :region, id: 1
      region.update_attributes :directline_account_number => '1234'
      expect(importer).to receive(:import_data).with(region, an_instance_of(String))

      controller.import_dispatch_v1({ "body" => "Test Account: 1234 Test" }, log)
    end

    it "Calls importer when an account is specified and default region exists" do
      region = FactoryGirl.create :region, id: 1
      c2 = FactoryGirl.create :region, id: 2
      c2.update_attributes :directline_account_number => '1234'
      expect(importer).to receive(:import_data).with(c2, an_instance_of(String))

      controller.import_dispatch_v1({ "body" => "Test Account: 1234 Test" }, log)
    end

    it "Doesn't call importer when an account is specified but doesn't exist" do
      region = FactoryGirl.create :region, id: 1
      expect(importer).not_to receive(:import_data)
      expect {
        controller.import_dispatch_v1({ "body" => "Test Account: 1234 Test" }, log)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end