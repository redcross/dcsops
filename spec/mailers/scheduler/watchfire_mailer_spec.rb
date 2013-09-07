require 'spec_helper'

=begin
describe Scheduler::WatchfireMailer do

  before(:each) do
    @chapter = FactoryGirl.create(:chapter)
    @county1 = FactoryGirl.create :county, chapter: @chapter
    @county2 = FactoryGirl.create :county, chapter: @chapter
    @position = FactoryGirl.create :position, chapter: @chapter, watchfire_role: 'dat'
    @position2 = FactoryGirl.create :position, chapter: @chapter, watchfire_role: nil
    @people1 = (0..5).map{|i| FactoryGirl.create :person, chapter: @chapter, counties:[@county1], positions: [@position]}
    @people2 = (0..5).map{|i| FactoryGirl.create :person, chapter: @chapter, counties:[@county1], positions: [@position2]}

    flex = Scheduler::FlexSchedule.create! id: @people1.first.id
    flex.available_monday_night = true
    flex.available_saturday_night = true
    flex.available_thursday_day = true
    flex.save!
  end

  let(:mail) { Scheduler::WatchfireMailer.export(@chapter)}
  let(:filename) { "#{@county1.name}.csv"}

context "Shift Data" do
  it "Should attach the file" do
    mail.attachments[filename].should_not be_nil
  end

  it "should parse as csv" do
    expect {
      CSV.parse(Base64.decode64 mail.attachments[filename].body.raw_source).should_not be_nil
    }.to_not raise_error
  end

  let (:csv) {CSV.parse(Base64.decode64 mail.attachments[filename].body.raw_source)}
  let (:header) {csv.first}

  it "should include a line each person with role plus header" do
    csv.count.should eq 6 + 1
  end

  it "Should have the person" do
    @person = @people1.first
    row = csv.detect{|r| r[0] == @person.id.to_s}
    row.should_not be_nil
  end

  it "Should have correct on call schedules" do
    @person = @people1.first
    row = csv.detect{|r| r[0] == @person.id.to_s}

    row[header.index("avail_saturday_1800")].should == 'false'
    row[header.index("avail_saturday_1900")].should == 'true'
    row[header.index("avail_saturday_2300")].should == 'true'
    row[header.index("avail_sunday_0000")].should == 'true'
    row[header.index("avail_sunday_0600")].should == 'true'
    row[header.index("avail_sunday_0700")].should == 'false'
    
    row[header.index("avail_monday_1800")].should == 'false'
    row[header.index("avail_monday_1900")].should == 'true'
    row[header.index("avail_monday_2300")].should == 'true'
    row[header.index("avail_tuesday_0000")].should == 'true'
    row[header.index("avail_tuesday_0600")].should == 'true'
    row[header.index("avail_tuesday_0700")].should == 'false'
    row[header.index("avail_tuesday_2300")].should == 'false'

    row[header.index("avail_thursday_0600")].should == 'false'
    row[header.index("avail_thursday_0700")].should == 'true'
    row[header.index("avail_thursday_1800")].should == 'true'
    row[header.index("avail_thursday_1900")].should == 'false'
  end
end
  
end

=end