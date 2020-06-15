require "spec_helper"

describe Scheduler::SwapMailer, :type => :mailer do
  let(:from_address) {["scheduling@dcsops.org"]}
  let(:assignment) {FactoryGirl.create :shift_assignment}
  let(:new_person) {FactoryGirl.create :person, region: assignment.person.region, shift_territories: assignment.person.shift_territories, positions: assignment.person.positions}

  describe "swap_available" do

    let(:mail) { Scheduler::SwapMailer.swap_available(assignment, nil, new_person) }
  
    it "renders the headers" do
      expect(mail.subject).to match("Shift Swap Requested")
      expect(mail.to).to eq([new_person.email])
      expect(mail.from).to eq from_address
      expect(mail.header['X-MC-Tags'].to_s).to eq('scheduler,swap,swap_available')
    end
  
    it "renders the body" do
      expect(mail.body.encoded).to match("Hello, #{new_person.first_name}")
      expect(mail.body.encoded).to match("#{assignment.person.full_name} has made a shift available for swap and is looking for someone to fill it.")
    end
  end
  
  describe "swap_confirmed" do
    let(:mail) { Scheduler::SwapMailer.swap_confirmed(assignment, assignment, new_person) }
  
    it "renders the headers" do
      expect(mail.subject).to match("Shift Swap Confirmed")
      expect(mail.to).to eq([new_person.email])
      expect(mail.from).to eq(from_address)
    end
  
    it "renders the body" do
      expect(mail.body.encoded).to match("This is to confirm that a DAT shift has been swapped.")
    end
  end

end
