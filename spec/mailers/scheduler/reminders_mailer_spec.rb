require "spec_helper"

describe Scheduler::RemindersMailer do
  let(:from_address) {["scheduling@dcsops.org"]}
  describe "email_invite" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.email_invite(assignment) }
  
    it "renders the headers" do
      mail.subject.should include(assignment.shift.name)
      mail.to.should eq([assignment.person.email])
      mail.from.should eq(from_address)
    end
  
    it "renders the body" do
      mail.body.encoded.should match(assignment.shift.name)
    end

    it "has an ics part" do
      mail.body.parts.count.should == 2
      mail.body.encoded.should match("text/calendar")
    end
  end

  describe "email_reminder" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.email_reminder(assignment) }
  
    it "renders the headers" do
      mail.subject.should include(assignment.shift.name)
      mail.to.should eq([assignment.person.email])
      mail.from.should eq(from_address)
    end
  
    it "renders the body" do
      mail.body.encoded.should match(assignment.shift.name)
    end
  end

  describe "sms_reminder" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.sms_reminder(assignment) }
  
    it "renders the headers" do
      mail.subject.should eq(nil)
      mail.to.should eq(assignment.person.sms_addresses)
      mail.from.should eq(["sms@dcsops.org"])
    end
  
    it "renders the body" do
      mail.body.encoded.should match(assignment.shift.name)
    end
  end

  context "daily reminders" do
    before(:each) do
      @chapter = FactoryGirl.create :chapter
      @admin = FactoryGirl.create :person, chapter: @chapter
      @group = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 0.hours, end_offset: 24.hours)
      @shift = FactoryGirl.create :shift, shift_group: @group, county: @admin.counties.first, positions: @admin.positions

      @person = FactoryGirl.create :person, chapter: @chapter, positions: @shift.positions, counties: [@shift.county]
      @ass = FactoryGirl.create :shift_assignment, shift: @shift, date: Date.current, person: @person
    
      @setting = Scheduler::NotificationSetting.create id: @admin.id
    end

    describe "daily_email_reminder" do
      let(:mail) { Scheduler::RemindersMailer.daily_email_reminder(@setting) }
    
      it "renders the headers" do
        mail.subject.should match("DAT Shifts")
        mail.to.should eq([@admin.email])
        mail.from.should eq(from_address)
      end
    
      it "renders the body" do
        mail.body.encoded.should match(@shift.name)
      end
    end

    describe "daily_sms_reminder" do
      let(:mail) { Scheduler::RemindersMailer.daily_sms_reminder(@setting) }
    
      it "renders the headers" do
        mail.subject.should be_nil
        mail.to.should eq(@admin.sms_addresses)
        mail.from.should eq(["sms@dcsops.org"])
      end
    
      it "renders the body" do
        mail.body.encoded.should match(@shift.abbrev)
      end
    end

    describe "daily_swap_reminder" do
      let(:mail) { Scheduler::RemindersMailer.daily_swap_reminder(@setting) }

      before(:each) do
        @setting.update_attribute :email_all_swaps_daily, true
        @ass.update_attribute :available_for_swap, true
      end

      describe "with a shift to swap" do

        it "renders the headers" do
          mail.subject.should match("Daily Shift Swaps Reminder")
          mail.to.should eq([@admin.email])
          mail.from.should eq(from_address)
        end
      
        it "renders the body" do
          mail.body.encoded.should match(@ass.person.full_name)
        end      

      end

      describe "with no shifts to swap" do

        it "should not deliver" do
          @ass.update_attribute :available_for_swap, false
          mail.perform_deliveries.should be_false
        end

      end

    end
  end
end