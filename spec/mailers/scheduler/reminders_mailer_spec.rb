require "spec_helper"

describe Scheduler::RemindersMailer, :type => :mailer do
  let(:from_address) {["scheduling@dcsops.org"]}
  describe "email_invite" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.email_invite(assignment) }
  
    it "renders the headers" do
      expect(mail.subject).to include(assignment.shift.name)
      expect(mail.to).to eq([assignment.person.email])
      expect(mail.from).to eq(from_address)
    end
  
    it "renders the body" do
      expect(mail.body.encoded).to match(assignment.shift.name)
    end

    it "has an ics part" do
      expect(mail.body.parts.count).to eq(2)
      expect(mail.body.encoded).to match("text/calendar")
    end
  end

  describe "email_reminder" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.email_reminder(assignment) }
  
    it "renders the headers" do
      expect(mail.subject).to include(assignment.shift.name)
      expect(mail.to).to eq([assignment.person.email])
      expect(mail.from).to eq(from_address)
    end
  
    it "renders the body" do
      expect(mail.body.encoded).to match(assignment.shift.name)
    end
  end

  describe "sms_reminder" do
    let(:assignment) { FactoryGirl.create :shift_assignment}
    let(:mail) { Scheduler::RemindersMailer.sms_reminder(assignment) }
  
    it "renders the headers" do
      expect(mail.subject).to eq(nil)
      expect(mail.to).to eq(assignment.person.sms_addresses)
      expect(mail.from).to eq(["sms@dcsops.org"])
    end
  
    it "renders the body" do
      expect(mail.body.encoded).to match(assignment.shift.name)
    end
  end

  context "daily reminders" do
    before(:each) do
      @chapter = FactoryGirl.create :chapter
      @admin = FactoryGirl.create :person, chapter: @chapter
      @group = FactoryGirl.create(:shift_group, chapter: @chapter, period: 'daily', start_offset: 0.hours, end_offset: 24.hours)
      @shift = FactoryGirl.create :shift, shift_groups: [@group], county: @admin.counties.first, positions: @admin.positions

      @person = FactoryGirl.create :person, chapter: @chapter, positions: @shift.positions, counties: [@shift.county]
      @ass = FactoryGirl.create :shift_assignment, shift: @shift, date: Date.current, person: @person, shift_group: @group
    
      @setting = Scheduler::NotificationSetting.create id: @admin.id
    end

    describe "daily_email_reminder" do
      let(:mail) { Scheduler::RemindersMailer.daily_email_reminder(@setting) }
    
      it "renders the headers" do
        expect(mail.subject).to match("DAT Shifts")
        expect(mail.to).to eq([@admin.email])
        expect(mail.from).to eq(from_address)
      end
    
      it "renders the body" do
        expect(mail.body.encoded).to match(@shift.name)
      end
    end

    describe "daily_sms_reminder" do
      let(:mail) { Scheduler::RemindersMailer.daily_sms_reminder(@setting) }
    
      it "renders the headers" do
        expect(mail.subject).to be_nil
        expect(mail.to).to eq(@admin.sms_addresses)
        expect(mail.from).to eq(["sms@dcsops.org"])
      end
    
      it "renders the body" do
        expect(mail.body.encoded).to match(@shift.abbrev)
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
          expect(mail.subject).to match("Daily Shift Swaps Reminder")
          expect(mail.to).to eq([@admin.email])
          expect(mail.from).to eq(from_address)
        end
      
        it "renders the body" do
          expect(mail.body.encoded).to match(@ass.person.full_name)
        end      

      end

      describe "with no shifts to swap" do

        it "should not deliver" do
          @ass.update_attribute :available_for_swap, false
          expect(mail.perform_deliveries).to be_falsey
        end

      end

    end
  end
end