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
    t.clear_changes_information
    t
  }

  let(:result) {
    double(:geocode_result, lat: Faker::Address.latitude, lng: Faker::Address.longitude, success?: true)
  }

  let(:geocoder) {Geokit::Geocoders::GoogleGeocoder}

  it "Should install before save handler" do
    expect(TestModel._save_callbacks).not_to be_empty
  end
  it "Should geocode if force is true" do
    expect(geocoder).to receive(:geocode).and_return(result)
    model.geocode_address(true)
  end
  it "Should geocode if lat and lng are nil" do
    expect(geocoder).to receive(:geocode).and_return(result)
    model.geocode_address(false)
  end
  it "Should geocode if the model has changed" do
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude

    model.address1_will_change!
    expect(geocoder).to receive(:geocode).and_return(result)
    model.geocode_address(false)
  end
  it "Should geocode all the address columns" do
    expect(geocoder).to receive(:geocode) do |address|
      expect(address).to eq("#{model.address1} #{model.city} #{model.state} #{model.zip}")
      result
    end
    model.geocode_address(true)
  end
  it "Should not geocode if force is false, have a lat and lng, and no changes" do
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude
    expect(geocoder).not_to receive(:geocode)
    model.geocode_address(false)
  end
  it "Should not error if a TooManyQueries error is raised" do
    expect(geocoder).to receive(:geocode).and_raise(Geokit::Geocoders::TooManyQueriesError)
    model.lat = Faker::Address.latitude
    model.lng = Faker::Address.longitude
    expect {
      model.geocode_address(true)
      expect(model.lat).to be_nil
      expect(model.lng).to be_nil
    }.to_not raise_error
  end

end