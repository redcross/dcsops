require 'spec_helper'

describe Roster::LoginService, :type => :model do
  subject { Roster::LoginService.new "username", "password" }

  before :each do
    Vc::Login.stub get_user: vc_info
  end

  let(:vc_info) {
    {
      :vc_id=>1234, 
      :dro_history=>[
        {:incident_name=>"Flood", :assign_date=>Date.civil(2013,9,18), :release_date=>Date.civil(2013,10,3), :gap=>"IP-ID-SV", :qualifications=>nil}, 
        {:incident_name=>"Tornado", :assign_date=>Date.civil(2013,11,21), :release_date=>Date.civil(2013,12,10), :gap=>"IP-ID-SV", :qualifications=>nil}
      ], 
      :first_name=>Faker::Name.first_name, 
      :last_name=>Faker::Name.last_name, 
      :address1=>"1 MISSION ST", 
      :address2=>"", 
      :city=>"SAN FRANCISCO", 
      :state=>"CA", 
      :zip=>"94103", 
      :email=>Faker::Internet.email, 
      :vc_member_number=>54321
    }.freeze
  }

  let!(:person) {
    FactoryGirl.create :person, vc_id: 1234, username: "test", password: "test"
  }

  it "should be creatable" do
    subject
  end

  it "should respond to deferred_update" do
    subject.deferred_update
  end

  it "should update an existing persons credentials" do
    expect {
      subject.call
    }.to_not change(Roster::Person, :count)
    
    person.reload
    expect(person.username).to eq('username')
  end

  it "should update an existing persons attributes" do
    subject.call
    person.reload
    [:address1, :address2, :city, :state, :zip, :email, :vc_member_number].each do |name|
      expect(person.send(name)).to eq(vc_info[name])
    end
  end

  it "should update a person's dr history"

  context "for a new user" do
    before do
      person.update_attribute :vc_id, 9999
      @chapter = Roster::Chapter.create! id: 0, name: 'Deployment'
    end

    let(:new_person) { Roster::Person.find_by(vc_id: 1234) }

    it "should create a person" do
      expect {
        subject.call
      }.to change(Roster::Person, :count).by(1)
    end

    it "should assign to chapter 0" do
      subject.call
      expect(new_person).not_to be_nil
      expect(new_person.chapter_id).to eq(0)
    end

    it "should not be active" do
      subject.call
      expect(new_person.vc_is_active).to be_falsey
    end

    it "should have basic attributes" do
      subject.call
      [:first_name, :last_name, :address1, :address2, :city, :state, :zip, :email, :vc_member_number].each do |name|
        expect(new_person.send(name)).to eq(vc_info[name])
      end
    end

  end

end
