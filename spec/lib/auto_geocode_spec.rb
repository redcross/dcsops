require 'spec_helper'

describe AutoGeocode do
  class TestModel
    include ActiveModel::Dirty
    extend ActiveModel::Callbacks
    define_model_callbacks :save

    include AutoGeocode

    

    attr_accessor :address1, :address2, :city, :state, :zip, :lat, :lng
    define_attribute_methods :address1, :address2, :city, :state, :zip, :lat, :lng

    def [](name)
      self.send(name)
    end

    def clear_changes
      changed_attributes.clear
    end
  end

  before(:all) { AutoGeocode.enabled_in_test = true }
  after(:all) { AutoGeocode.enabled_in_test = false }

  let(:model) { 
    t = TestModel.new
    t.address1 = Faker::Address.street_address
    t.city = Faker::Address.city
    t.state = Faker::Address.state
    t.zip = Faker::Address.zip
    t.clear_changes
    t
  }

  let(:result) {
    double(:geocode_result, lat: Faker::Address.latitude, lng: Faker::Address.longitude)
  }

  let(:geocoder) {Geokit::Geocoders::GoogleGeocoder}

  it "Should install before save handler" do
    TestModel._save_callbacks.should_not be_empty
  end
  it "Should geocode if force is true" do
    geocoder.should_receive(:geocode).and_return(result)
    model.geocode_address(true)
  end
  it "Should geocode if lat and lng are nil" do
    geocoder.should_receive(:geocode).and_return(result)
    model.geocode_address(false)
  end
  it "Should geocode if the model has changed" do
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude

    model.address1_will_change!
    geocoder.should_receive(:geocode).and_return(result)
    model.geocode_address(false)
  end
  it "Should geocode all the address columns" do
    geocoder.should_receive(:geocode) do |address|
      address.should == "#{model.address1} #{model.city} #{model.state} #{model.zip}"
      result
    end
    model.geocode_address(true)
  end
  it "Should not geocode if force is false, have a lat and lng, and no changes" do
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude
    geocoder.should_not_receive(:geocode)
    model.geocode_address(false)
  end
  it "Should not error if a TooManyQueries error is raised" do
    geocoder.should_receive(:geocode).and_raise(Geokit::Geocoders::TooManyQueriesError)
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude
    expect {
      model.geocode_address(true)
      model.lat.should be_nil
      model.lng.should be_nil
    }.to_not raise_error
  end

end