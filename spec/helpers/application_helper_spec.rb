require 'spec_helper'

describe ApplicationHelper, :type => :helper do
  it "provides an asset_url" do
    expect(helper.asset_url("map-icons/person-icon.png")).to eq("http://test.host/assets/map-icons/person-icon.png")
  end

  describe '#current_messages' do
    let(:region) { FactoryGirl.create :region }
    let!(:motd) { FactoryGirl.create :motd, region: region }
    let(:user) { mock_model Roster::Person }

    before(:each) {
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_region).and_return(region)
    }

    it "returns nothing if motds aren't turned on" do
      expect(helper.current_messages).to match_array([])
    end

    it "returns the motd if motds are turned on" do
      expect(ENV).to receive(:[]).with("MOTD_ENABLED").and_return(true)
      expect(helper.current_messages).to match_array([motd])
    end
  end

end