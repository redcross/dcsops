require "spec_helper"

describe Scheduler::SwapMailer do
  let(:from_address) {["scheduling@dcsops.org"]}
  let(:assignment) {FactoryGirl.create :shift_assignment}
  let(:new_person) {FactoryGirl.create :person, chapter: assignment.person.chapter, counties: assignment.person.counties, positions: assignment.person.positions}

  describe "swap_available" do

    let(:mail) { Scheduler::SwapMailer.swap_available(assignment, nil, new_person) }
  
    it "renders the headers" do
      mail.subject.should match("Shift Swap Requested")
      mail.to.should eq([new_person.email])
      mail.from.should eq from_address
      mail.header['X-MC-Tags'].to_s.should eq('scheduler,swap,swap_available')
    end
  
    it "renders the body" do
      mail.body.encoded.should match("Hello, #{new_person.first_name}")
      mail.body.encoded.should match("#{assignment.person.full_name} has made a shift available for swap and is looking for someone to fill it.")
    end
  end
  
  describe "swap_confirmed" do
    let(:new_shift) {assignment.swap_to(new_person)}
    let(:mail) { Scheduler::SwapMailer.swap_confirmed(assignment, new_shift) }
  
    it "renders the headers" do
      mail.subject.should match("Shift Swap Confirmed")
      mail.to.should eq([assignment.person.email, new_person.email])
      mail.from.should eq(from_address)
    end
  
    it "renders the body" do
      mail.body.encoded.should match("This is to confirm that a DAT shift has been swapped.")
    end
  end

end
