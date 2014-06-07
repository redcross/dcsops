require 'spec_helper'

describe Scheduler::DirectlineMailer do

  before(:each) do
    @chapter = FactoryGirl.create(:chapter)
    @county1 = FactoryGirl.create :county, chapter: @chapter
    @county2 = FactoryGirl.create :county, chapter: @chapter
    @position = FactoryGirl.create :position, chapter: @chapter
    @people1 = (0..5).map{|i| FactoryGirl.create :person, chapter: @chapter, counties:[@county1], positions: [@position]}
    #@people2 = (0..5).map{|i| FactoryGirl.create :person, counties:[@county2], positions: [@position]}

    @day = FactoryGirl.create :shift_group, chapter: @chapter, start_offset: 7.hours, end_offset: 19.hours
    @night = FactoryGirl.create :shift_group, chapter: @chapter, start_offset: 19.hours, end_offset: 31.hours

    @leadshift = FactoryGirl.create :shift, shift_groups: [@day, @night], dispatch_role: 1, positions: [@position], county: @county1
    @othershift = FactoryGirl.create :shift, shift_groups: [@day, @night], positions: [@position], county: @county1

    @leadass = FactoryGirl.create :shift_assignment, person: @people1.first, date: today, shift: @leadshift, shift_group: @day
    FactoryGirl.create :shift_assignment, person: @people1[1], date: today, shift: @othershift, shift_group: @day
    FactoryGirl.create :shift_assignment, person: @people1[2], date: today, shift: @leadshift, shift_group: @night

    @config = Scheduler::DispatchConfig.new county: @county1, name: @county1.name
    @config.is_active = true
    @config.backup_first = @people1.last
    @config.save!
  end

  let(:today) { @chapter.time_zone.today }
  let(:mail) { Scheduler::DirectlineMailer.export(@chapter, today, today.tomorrow)}
  let(:shift_filename) { "shift_data.csv"}
  let(:roster_filename) { "roster.csv"}

  context "Shift Data" do
    it "Should attach the file" do
      mail.attachments[shift_filename].should_not be_nil
    end

    it "should parse as csv" do
      expect {
        CSV.parse(mail.attachments[shift_filename].body.raw_source).should_not be_nil
      }.to_not raise_error
    end

    let (:csv) {CSV.parse(mail.attachments[shift_filename].body.raw_source)}

    it "should include a line for each day/shift group plus header" do
      csv.count.should eq 4 + 1
    end

    it "Should have the on call person plus backups" do
      row = csv[1]
      row[1].should eq (@chapter.time_zone.now.at_beginning_of_day.advance(seconds: @day.start_offset).iso8601)
      row[3..row.count].should =~ [@people1.first.id.to_s, @config.backup_first.id.to_s]
    end

    it "Should have the night person plus backups" do
      row = csv[2]
      row[1].should eq (@chapter.time_zone.now.at_beginning_of_day.advance(seconds: @night.start_offset).iso8601)
      row[3..row.count].should =~ [@people1[2].id.to_s, @config.backup_first.id.to_s]
    end

    it "Should have the backups when no on call person" do
      row = csv[3]
      row[1].should eq (@chapter.time_zone.now.at_beginning_of_day.advance(days: 1, seconds: @day.start_offset).iso8601)
      row[3..row.count].should =~ [@config.backup_first.id.to_s]
    end

    it "Should include a weekly backup shift" do
      @week = FactoryGirl.create :shift_group, chapter: @chapter, start_offset: 7.hours, end_offset: ((24 * 7) + 7).hours, period: 'weekly'
      @weekshift = FactoryGirl.create :shift, shift_groups: [@week], dispatch_role: 3, positions: [@position], county: @county1
      @weekperson = @people1[3]
      @weekass = FactoryGirl.create :shift_assignment, person: @weekperson, date: today.at_beginning_of_week, shift: @weekshift, shift_group: @week

      row = csv[1]
      row[3..row.count].should =~ [@people1.first.id.to_s, @weekperson.id.to_s, @config.backup_first.id.to_s]
    end
  end

  context "Person data" do
    it "Should attach the file" do
      mail.attachments[roster_filename].should_not be_nil
    end

    it "should parse as csv" do
      expect {
        CSV.parse(mail.attachments[roster_filename].body.raw_source).should_not be_nil
      }.to_not raise_error
    end

    let (:csv) {CSV.parse(mail.attachments[roster_filename].body.raw_source)}

    it "should have rows for everyone plus header" do
      csv.count.should eq 3 + 1
    end 

    it "should identify an SMS number" do
      carrier = FactoryGirl.create :cell_carrier
      person = @people1.first
      person.update_attribute :work_phone_carrier, carrier

      row = csv.detect{|row| row[0].to_i == person.id}
      row.should_not be_nil

      number = person.work_phone.gsub /[^0-9]/, ''

      row[3].should == number # Primary Phone
      row[5].should == number # correctly detected SMS carrier
      row[8].should == 'phone'
    end

    it "should identify a pager number" do
      carrier = FactoryGirl.create :cell_carrier, pager: true
      person = @people1.first
      person.update_attribute :work_phone_carrier, carrier

      row = csv.detect{|row| row[0].to_i == person.id}
      row.should_not be_nil

      number = person.work_phone.gsub /[^0-9]/, ''

      row[3].should == number # Primary Phone
      row[5].should_not be_present # when carrier is a pager, don't present as SMS
      row[8].should == 'pager'
    end
  end
  
end