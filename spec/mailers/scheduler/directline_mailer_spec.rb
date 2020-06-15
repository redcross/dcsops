require 'spec_helper'

describe Scheduler::DirectlineMailer, :type => :mailer do

  before(:each) do
    @region = FactoryGirl.create(:region)
    @shift_territory1 = FactoryGirl.create :shift_territory, region: @region
    @shift_territory2 = FactoryGirl.create :shift_territory, region: @region
    @position = FactoryGirl.create :position, region: @region
    @people1 = (0..5).map{|i| FactoryGirl.create :person, region: @region, shift_territories:[@shift_territory1], positions: [@position]}
    #@people2 = (0..5).map{|i| FactoryGirl.create :person, shift_territories:[@shift_territory2], positions: [@position]}

    @day = FactoryGirl.create :shift_time, region: @region, start_offset: 7.hours, end_offset: 19.hours
    @night = FactoryGirl.create :shift_time, region: @region, start_offset: 19.hours, end_offset: 31.hours

    @leadshift = FactoryGirl.create :shift, shift_times: [@day, @night], positions: [@position], shift_territory: @shift_territory1
    @othershift = FactoryGirl.create :shift, shift_times: [@day, @night], positions: [@position], shift_territory: @shift_territory1

    @leadass = FactoryGirl.create :shift_assignment, person: @people1.first, date: today, shift: @leadshift, shift_time: @day
    FactoryGirl.create :shift_assignment, person: @people1[1], date: today, shift: @othershift, shift_time: @day
    FactoryGirl.create :shift_assignment, person: @people1[2], date: today, shift: @leadshift, shift_time: @night

    @config = Scheduler::DispatchConfig.new region: @region, name: @shift_territory1.name
    @config.is_active = true
    @config.shift_first = @leadshift
    @config.backup_first = @people1.last
    @config.save!
  end

  let(:today) { @region.time_zone.today }
  let(:mail) { Scheduler::DirectlineMailer.export(@region, today, today.tomorrow)}
  let(:shift_filename) { "shift_data.csv"}
  let(:roster_filename) { "roster.csv"}

  context "Shift Data" do
    it "Should attach the file" do
      expect(mail.attachments[shift_filename]).not_to be_nil
    end

    it "should parse as csv" do
      expect {
        expect(CSV.parse(mail.attachments[shift_filename].body.raw_source)).not_to be_nil
      }.to_not raise_error
    end

    let (:csv) {CSV.parse(mail.attachments[shift_filename].body.raw_source)}

    it "should include a line for each day/shift time plus header" do
      expect(csv.count).to eq 4 + 1
    end

    it "Should have the on call person plus backups" do
      row = csv[1]
      expect(row[1]).to eq (@region.time_zone.now.at_beginning_of_day.advance(seconds: @day.start_offset).iso8601)
      expect(row[3..row.count]).to match_array([@people1.first.id.to_s, @config.backup_first.id.to_s])
    end

    it "Should have the night person plus backups" do
      row = csv[2]
      expect(row[1]).to eq (@region.time_zone.now.at_beginning_of_day.advance(seconds: @night.start_offset).iso8601)
      expect(row[3..row.count]).to match_array([@people1[2].id.to_s, @config.backup_first.id.to_s])
    end

    it "Should have the backups when no on call person" do
      row = csv[3]
      expect(row[1]).to eq (@region.time_zone.now.at_beginning_of_day.advance(days: 1, seconds: @day.start_offset).iso8601)
      expect(row[3..row.count]).to match_array([@config.backup_first.id.to_s])
    end

    it "Should include a weekly backup shift" do
      @week = FactoryGirl.create :shift_time, region: @region, start_offset: 7.hours, end_offset: ((24 * 7) + 7).hours, period: 'weekly'
      @weekshift = FactoryGirl.create :shift, shift_times: [@week], positions: [@position], shift_territory: @shift_territory1
      @config.update_attributes! shift_second_id: @weekshift.id
      @weekperson = @people1[3]
      @weekass = FactoryGirl.create :shift_assignment, person: @weekperson, date: today.at_beginning_of_week, shift: @weekshift, shift_time: @week

      row = csv[1]
      expect(row[3..row.count]).to match_array([@people1.first.id.to_s, @weekperson.id.to_s, @config.backup_first.id.to_s])
    end
  end

  context "Person data" do
    it "Should attach the file" do
      expect(mail.attachments[roster_filename]).not_to be_nil
    end

    it "should parse as csv" do
      expect {
        expect(CSV.parse(mail.attachments[roster_filename].body.raw_source)).not_to be_nil
      }.to_not raise_error
    end

    let (:csv) {CSV.parse(mail.attachments[roster_filename].body.raw_source)}

    it "should have rows for everyone plus header" do
      expect(csv.count).to eq 3 + 1
    end 

    it "should identify an SMS number" do
      carrier = FactoryGirl.create :cell_carrier
      person = @people1.first
      person.update_attribute :work_phone_carrier, carrier

      row = csv.detect{|row| row[0].to_i == person.id}
      expect(row).not_to be_nil

      number = person.work_phone.gsub /[^0-9]/, ''

      expect(row[3]).to eq(number) # Primary Phone
      expect(row[5]).to eq(number) # correctly detected SMS carrier
      expect(row[8]).to eq('phone')
    end

    it "should identify a pager number" do
      carrier = FactoryGirl.create :cell_carrier, pager: true
      person = @people1.first
      person.update_attribute :work_phone_carrier, carrier

      row = csv.detect{|row| row[0].to_i == person.id}
      expect(row).not_to be_nil

      number = person.work_phone.gsub /[^0-9]/, ''

      expect(row[3]).to eq(number) # Primary Phone
      expect(row[5]).not_to be_present # when carrier is a pager, don't present as SMS
      expect(row[8]).to eq('pager')
    end
  end
  
end