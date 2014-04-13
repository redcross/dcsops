require 'spec_helper'

describe ApplicationHelper do
  it "provides an asset_url" do
    helper.asset_url("map-icons/person-icon.png").should == "http://test.host/assets/map-icons/person-icon.png"
  end

  describe '#current_messages' do
    let(:chapter) { FactoryGirl.create :chapter }
    let!(:motd) { FactoryGirl.create :motd, chapter: chapter }
    let(:user) { mock_model Roster::Person }

    before(:each) {
      helper.stub current_user: user, current_chapter: chapter
    }

    it "returns nothing if motds aren't turned on" do
      helper.current_messages.should =~ []
    end

    it "returns the motd if motds are turned on" do
      ENV.should_receive(:[]).with("MOTD_ENABLED").and_return(true)
      helper.current_messages.should =~ [motd]
    end
  end

end