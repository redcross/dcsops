require 'spec_helper'

describe Vc::Login do

  let(:credentials) { double(username: (ENV['VC_USERNAME'] || 'username'), password: (ENV['VC_PASSWORD'] || 'password'))}

  def load_fixture name
    File.read "spec/fixtures/vc/login/#{name}"
  end

  let(:service) { Vc::Login.new credentials.username, credentials.password }

  describe "incorrect credentials" do

    it "raises an error", vcr: true do
      expect {
        Vc::Login.get_user 'incorrect_username', 'incorrect_password'
      }.to raise_error(Vc::Login::InvalidCredentials)
    end

  end

  # Dump HTML Fixtures:
  str = <<-CMD
  h = YAML.load(File.read "spec/cassettes/Vc_Login/makes_a_query_with_uneditable_name.yml"); 
  File.open("spec/fixtures/vc/login/profile-2-edit.html", "w") { |f| f.write h['http_interactions'][1]['response']['body']['string'] }
  CMD

  # Update from HTML Fixtures:
  str = <<-CMD
  h = YAML.load(File.read "spec/cassettes/Vc_Login/makes_a_query_with_uneditable_name.yml"); 
  h['http_interactions'][0]['response']['body']['string'] = File.read("spec/fixtures/vc/login/profile-2.html"); 
  h['http_interactions'][1]['response']['body']['string'] = File.read("spec/fixtures/vc/login/profile-2-edit.html"); 
  File.open("spec/cassettes/Vc_Login/makes_a_query_with_uneditable_name.yml", "w") { |f| f.write YAML.dump(h) }
  CMD

  it "makes a query with editable name", vcr: true do
    #Vc::Login.should_receive(:post).with('/', anything).and_return(double(:response, body: load_fixture("profile-1.html")))
    data = Vc::Login.get_user credentials.username, credentials.password
    data.should be_a(Hash)
    
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
      :vc_member_number=>123456,
      :cell_phone=>"555-555-1212",
      :work_phone=>nil,
      :home_phone=>nil,
      :alternate_phone=>nil,
      :sms_phone=>nil,
      :phone_1_preference => 'cell',
      :phone_2_preference => nil,
      :phone_3_preference => nil,
      :phone_4_preference => nil
    }
    data.should == expected
  end

  it "makes a query with uneditable name", vcr: true do
    #Vc::Login.should_receive(:post).with('/', anything).and_return(double(:response, body: load_fixture("profile-1.html")))
    data = Vc::Login.get_user credentials.username, credentials.password
    data.should be_a(Hash)
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
      :address1=>"555 ANY ST",
      :address2=>"APT 555",
      :city=>"SOME CITY",
      :state=>"CA",
      :zip=>"55555",
      :email=>"bob@example.org",
      :vc_member_number=>123456,
      :cell_phone=>"555-555-1212",
      :work_phone=>"555-555-1213",
      :home_phone=>"555-555-1214",
      :alternate_phone=>"555-555-1215",
      :sms_phone=>"555-555-1216",
      :phone_1_preference => 'cell',
      :phone_2_preference => 'alternate',
      :phone_3_preference => 'work',
      :phone_4_preference => 'home'
    }
    data.should == expected
  end

  #it "Parses a profile" do
  #  data = load_fixture "profile-1.html"
  #  details = service.extract_data data
  #  
  #  expected = {
  #    :vc_id=>123123,
  #    :dro_history=>
  #      [{:incident_name=>"Some DR 7/13 WW",
  #        :assign_date=>Date.civil(2011,7,1),
  #        :release_date=>Date.civil(2011,7,14),
  #        :gap=>"AA/AB/AC",
  #        :qualifications=>nil}],
  #    :first_name=>"Bob",
  #    :last_name=>"Boberson",
  #    :address1=>"123 ANY ST",
  #    :address2=>"APT 555",
  #    :city=>"SOME TOWN",
  #    :state=>"CA",
  #    :zip=>"55555",
  #    :email=>"bob@example.org",
  #    :vc_member_number=>123456
  #  }
#
  #  details.should == expected
  #end
#
  #it "Parses a profile without an address" do
  #  data = load_fixture "profile-without-address.html"
  #  details = service.extract_data data
  #  details[:vc_id].should == 123123
  #end
#
  #it "Parses a profile with an address without a county" do
  #  data = load_fixture "profile-without-county.html"
  #  details = service.extract_data data
  #  details[:vc_id].should == 123123
  #  details[:address1].should be_nil
  #end
#
  #it "Parses a profile with an unparseable address" do
  #  data = load_fixture "profile-with-unparseable-address.html"
  #  details = service.extract_data data
  #  details[:vc_id].should == 123123
  #  details[:address1].should be_nil
  #end

  
end