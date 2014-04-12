require 'spec_helper'

describe Vc::Login do

  def load_fixture name
    File.read "spec/fixtures/vc/login/#{name}"
  end

  let(:service) { Vc::Login.new "username", "password" }

  it "Makes a query" do
    Vc::Login.should_receive(:post).with('/', anything).and_return(double(:response, body: load_fixture("profile-1.html")))
    data = Vc::Login.get_user 'username', 'password'
    data.should be_a(Hash)
    data[:vc_id].should == 123123
  end

  it "Parses a profile" do
    data = load_fixture "profile-1.html"
    details = service.extract_data data
    
    expected = {
      :vc_id=>123123,
      :dro_history=>
        [{:incident_name=>"Some DR 7/13 WW",
          :assign_date=>Date.civil(2011,7,1),
          :release_date=>Date.civil(2011,7,14),
          :gap=>"AA/AB/AC",
          :qualifications=>nil}],
      :first_name=>"Bob",
      :last_name=>"Boberson",
      :address1=>"123 ANY ST",
      :address2=>"APT 555",
      :city=>"SOME TOWN",
      :state=>"CA",
      :zip=>"55555",
      :email=>"bob@example.org",
      :vc_member_number=>123456
    }

    details.should == expected
  end

  it "Parses a profile without an address" do
    data = load_fixture "profile-without-address.html"
    details = service.extract_data data
    details[:vc_id].should == 123123
  end

  it "Parses a profile with an address without a county" do
    data = load_fixture "profile-without-county.html"
    details = service.extract_data data
    details[:vc_id].should == 123123
    details[:address1].should be_nil
  end

  it "Parses a profile with an unparseable address" do
    data = load_fixture "profile-with-unparseable-address.html"
    details = service.extract_data data
    details[:vc_id].should == 123123
    details[:address1].should be_nil
  end

  
end