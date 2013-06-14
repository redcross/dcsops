require 'spec_helper'

describe Incidents::ImportController do

  before(:each) do 
    @chapter = FactoryGirl.create :chapter
    ENV['MAILER_IMPORT_SECRET'] = SecureRandom.hex(12)
  end

  let(:key) { ENV['MAILER_IMPORT_SECRET'] }
  let(:file) {
    str = File.read "/Users/jlaxson/Desktop/ARCDATA CAS Export.xls"
  }

  describe "HEAD 'import-cas'" do
    it "returns http success" do
      head 'import_cas', provider: 'mandrill', import_secret: key, version: '1'
      response.should be_success
    end
  end

  describe "POST" do
    xit "should succeed" do
      post :import_cas, {
        provider: 'mandrill',
        import_secret: key,
        version: '1',
        format: 'json',
        message: {
          event: 'inbound',
          msg: {
            subject: @chapter.code,
            attachments: [{
              content: file
            }]
          }
        }
      }
      response.should be_success
    end
  end

end
